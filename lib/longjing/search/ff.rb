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

  module Search
    def self.ff
      FF
    end

    class FF < Base
      include Longjing::FF

      def search(problem)
        log { 'FF search starts' }
        log { 'Preprocess' }
        problem = Preprocess.new.execute(problem)
        log { 'Propositionalized problem:' }
        log { "# actions: #{problem.all_actions.size}" }
        log { 'Initialize graphs' }
        cg = ConnectivityGraph.new(problem)
        h = RelaxedGraphPlan.new(cg)

        log { "Build goal agenda" }
        agenda = Ordering.new(cg).goal_agenda(problem)
        log { "Goal agenda:" }
        log(:facts, agenda)
        goal = []
        state = problem.initial
        agenda.each do |g|
          goal << g
          unless state = hill_climbing(problem, state, h, goal)
            return greedy_search(problem, h)
          end
        end
        solution(state)
      end

      def hill_climbing(problem, state, h, goal_list)
        log { "Hill climbing, goal:" }
        log(:facts, goal_list)
        reset_best_heuristic

        best = if relaxed_solution = h.extract(goal_list, state)
                 distance(relaxed_solution)
               end
        logger.debug { "Initial cost: #{best}" }
        return unless best
        state.cost = best
        helpful_actions = relaxed_solution[1]
        goal_set = goal_list.to_set
        until best == 0 do
          state, best, helpful_actions = breadth_first(problem, [state],
                                                       best, h,
                                                       helpful_actions,
                                                       goal_set,
                                                       goal_list)
          return unless state
          logger.debug { "----\nState: #{state}\nCost: #{best}\nPath: #{state.path.map(&:signature).join("\n")}" }
        end
        state
      end

      def breadth_first(problem, frontier, best, h, helpful_actions,
                        goal_set, goal_list)
        known = Hash[frontier.map{|f| [f, true]}]
        until frontier.empty? do
          state = frontier.shift
          statistics.expanded += 1

          log(:exploring, state)
          log_progress(state)

          actions = helpful_actions || problem.actions(state)
          helpful_actions = nil
          actions.each do |action|
            new_state = problem.result(action, state)
            statistics.generated += 1
            log(:action, action, new_state)
            if known.include?(new_state)
              logger.debug { "Known state" }
              next
            end

            added_goals = Hash[action.effect.to_a.select{|lit| goal_set.include?(lit)}.map{|k| [k, true]}]
            if solution = h.extract(goal_list, new_state, added_goals)
              dist = distance(solution)
              new_state.cost = dist
              log(:heuristic, new_state, solution, dist, best)
              if dist < best
                return [new_state, dist, solution[1]]
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

      def greedy_search(problem, h)
        reset_best_heuristic
        goal_list = problem.goal.to_a
        greedy = Longjing::Search::Greedy.new
        heuristic = lambda {|state| distance(h.extract(goal_list, state))}
        greedy.search(problem, heuristic)
      end

      def distance(solution)
        return Float::INFINITY if solution.nil?
        if solution[0].empty?
          0
        else
          solution[0].map(&:size).reduce(:+)
        end
      end
    end
  end
end
