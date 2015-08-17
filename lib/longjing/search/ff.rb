require 'set'
require 'longjing/search/base'
require 'longjing/ff/preprocess'
require 'longjing/ff/connectivity_graph'
require 'longjing/ff/ordering'
require 'longjing/ff/relaxed_graph_plan'

module Longjing
  module PDDL
    class Literal
      attr_accessor :ff_neg_goal
    end
  end

  class State
    attr_accessor :ff_helpful_actions
  end

  module Search
    def self.ff
      FF
    end

    class FF < Base
      include Longjing::FF

      def init(problem)
        log { 'Preprocess' }
        @problem = Preprocess.new.execute(problem)
        log { 'Propositionalized problem:' }
        log { "# actions: #{@problem.all_actions.size}" }
        log { 'Initialize graphs' }
        cg = ConnectivityGraph.new(@problem)
        @h = RelaxedGraphPlan.new(cg)
        @ordering = Ordering.new(cg)
      end

      def search(problem)
        log { 'FF search starts' }
        init(problem)
        log { "Build goal agenda" }
        agenda = @ordering.goal_agenda(@problem)
        log { "Goal agenda:" }
        log(:facts, agenda)
        goal = []
        state = @problem.initial
        agenda.each do |g|
          goal << g
          unless state = hill_climbing(state, goal)
            log { "Hill climbing dead end, switch to greedy search" }
            return greedy_search
          end
        end
        solution(state)
      end

      def hill_climbing(state, goal_list)
        log { "Hill climbing, goal:" }
        log(:facts, goal_list)
        reset_best_heuristic

        best = if relaxed_solution = @h.extract(goal_list, state)
                 distance(relaxed_solution)
               end
        logger.debug { "Initial cost: #{best}" }
        return unless best
        state.cost = best
        state.ff_helpful_actions = relaxed_solution[1]
        statistics.evaluated += 1
        goal_set = goal_list.to_set
        until best == 0 do
          state, best = breadth_first([state],
                                      best,
                                      goal_set,
                                      goal_list)
          return unless state
        end
        state
      end

      def breadth_first(frontier, best, goal_set, goal_list)
        known = Hash[frontier.map{|f| [f, true]}]
        until frontier.empty? do
          state = frontier.shift

          log(:exploring, state)
          log_progress(state)

          if actions = state.ff_helpful_actions
            actions.select!(&@problem.applicable(state))
          end
          if actions.nil? || actions.empty?
            actions = @problem.actions(state)
          end
          statistics.expanded += 1

          actions.each do |action|
            new_state = @problem.result(action, state)
            statistics.generated += 1
            log(:action, action, new_state)
            if known.include?(new_state)
              logger.debug { "Known state" }
              next
            end

            added_goals = Hash[action.effect.to_a.select{|lit| goal_set.include?(lit)}.map{|k| [k, true]}]
            if solution = @h.extract(goal_list, new_state, added_goals)
              dist = distance(solution)
              new_state.cost = dist
              new_state.ff_helpful_actions = solution[1]
              log(:heuristic, new_state, solution, dist, best)
              if dist < best
                return [new_state, dist]
              else
                known[new_state] = true
                frontier << new_state
              end
            else
              # ignore infinite heuristic state
              logger.debug { "No relaxed solution" }
            end
            statistics.evaluated += 1
          end
        end
        return nil
      end

      def greedy_search
        reset_best_heuristic
        goal_list = @problem.goal.to_a
        greedy = Greedy.new
        heuristic = lambda {|state| distance(@h.extract(goal_list, state))}
        greedy.search(@problem, heuristic)
      end


      def distance(relaxed)
        return Float::INFINITY if relaxed.nil?
        if relaxed[0].empty?
          0
        else
          relaxed[0].map(&:size).reduce(:+)
        end
      end
    end
  end
end
