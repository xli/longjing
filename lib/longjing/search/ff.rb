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

        relaxed_solution = @h.extract(goal_list, state)
        statistics.evaluated += 1
        return if relaxed_solution.nil?
        state.cost = distance(relaxed_solution)
        state.ff_helpful_actions = relaxed_solution[1]
        logger.debug { "Initial cost: #{state.cost}" }
        goal_set = goal_list.to_set
        until state.cost == 0 do
          state = breadth_first([state], goal_set, goal_list)
          return if state.nil?
        end
        state
      end

      def breadth_first(frontier, goal_set, goal_list)
        known = {frontier[0] => true}
        best = frontier[0].cost
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
          actions.each do |action|
            new_state = @problem.result(action, state)
            statistics.generated += 1
            log(:action, action, new_state)
            if known.include?(new_state)
              logger.debug { "Known state" }
              next
            end

            relaxed_solution = @h.extract(goal_list,
                                          new_state,
                                          added_goals(action, goal_set))
            statistics.evaluated += 1
            if relaxed_solution.nil?
              # ignore infinite heuristic state
              logger.debug { "No relaxed solution" }
            else
              new_state.cost = distance(relaxed_solution)
              new_state.ff_helpful_actions = relaxed_solution[1]
              log(:heuristic, new_state, relaxed_solution, best)
              if new_state.cost < best
                return new_state
              else
                known[new_state] = true
                frontier << new_state
              end
            end
          end
          statistics.expanded += 1
        end
      end

      def greedy_search
        reset_best_heuristic
        goal_list = @problem.goal.to_a
        greedy = Greedy.new
        heuristic = lambda {|state| distance(@h.extract(goal_list, state))}
        greedy.search(@problem, heuristic)
      end

      def added_goals(action, goal_set)
        ret = {}
        action.effect.to_a.each do |lit|
          if goal_set.include?(lit)
            ret[lit] = true
          end
        end
        ret
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
