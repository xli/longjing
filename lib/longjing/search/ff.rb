require 'set'
require 'longjing/search/base'
require 'longjing/ff/connectivity_graph'
require 'longjing/ff/ordering'
require 'longjing/ff/relaxed_graph_plan'

module Longjing
  module PDDL
    class Literal
      attr_accessor :neg_goal
    end
  end

  module Search
    def self.ff
      FF
    end

    class FF < Base
      module NegGoal
        def applicable?(set)
          set.include?(self)
        end
        def apply(set)
          set << self
        end
      end

      def search(problem)
        log { 'FF search starts' }
        log { 'Propositionalize actions' }
        problem = propositionalize(problem)

        log { 'Handle negative goals' }
        reverse_negative_goals(problem.goal)
        log { 'Initialize graphs' }
        cg = Longjing::FF::ConnectivityGraph.new(problem)
        h = Longjing::FF::RelaxedGraphPlan.new(cg)

        log { "Build goal agenda" }
        agenda = Longjing::FF::Ordering.new(cg).goal_agenda(problem)
        log { "Goal agenda: #{agenda.join(" ")}" }
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
        log { "Hill climbing, goal: #{goal_list}" }
        best = if relaxed_solution = h.extract(goal_list, state)
                 distance(relaxed_solution)
               end
        logger.debug { "Initial cost: #{best}" }
        return unless best
        helpful_actions = relaxed_solution[1]
        goal_set = goal_list.to_set
        until best == 0 do
          state, best, helpful_actions = breadth_first(problem, [state],
                                                       best, h,
                                                       helpful_actions,
                                                       goal_set,
                                                       goal_list)
          return unless state
          log { "----\nState: #{state}\nCost: #{best}\nPath: #{state.path.map(&:signature).join("\n")}" }
        end
        state
      end

      def breadth_first(problem, frontier, best, h, helpful_actions,
                        goal_set, goal_list)
        known = Hash[frontier.map{|f| [f, true]}]
        until frontier.empty? do
          state = frontier.shift
          log(:exploring, state)
          actions = helpful_actions || problem.actions(state)
          helpful_actions = nil
          actions.each do |action|
            new_state = problem.result(action, state)
            log(:action, action, new_state)
            if known.include?(new_state)
              logger.debug { "Known state" }
              next
            end

            added_goals = Hash[action.effect.to_a.select{|lit| goal_set.include?(lit)}.map{|k| [k, true]}]
            if solution = h.extract(goal_list, new_state, added_goals)
              dist = distance(solution)
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
          end
        end
        return nil
      end

      def greedy_search(problem, h)
        goal_list = problem.goal.to_a
        greedy = Longjing::Search::Greedy.new
        heuristic = lambda {|state| distance(h.extract(goal_list, state))}
        greedy.search(problem, heuristic)
      end

      def propositionalize(problem)
        actions = problem[:actions].map do |action|
          params = Parameters.new(action)
          params.propositionalize(problem[:objects])
        end.flatten
        Problem.new(actions, problem[:init], problem[:goal])
      end

      def distance(solution)
        return nil if solution.nil?
        if solution[0].empty?
          0
        else
          solution[0].map(&:size).reduce(:+)
        end
      end

      def reverse_negative_goals(goal)
        case goal
        when PDDL::And
          goal.literals.each do |lit|
            reverse_negative_goals(lit)
          end
        when PDDL::Not
          goal.extend(NegGoal)
          goal.neg_goal = true
        end
      end
    end
  end
end
