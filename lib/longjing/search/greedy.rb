require 'set'
require 'longjing/search/base'

module Longjing
  module Search
    class Greedy < Base
      def search(problem, heuristic)
        log { "Greedy search" }
        initial = problem.initial
        if problem.goal?(initial)
          return solution(initial)
        end
        initial.cost = heuristic.call(initial)
        statistics.evaluated += 1

        frontier = SortedSet.new([initial])
        known = {initial => true}
        until frontier.empty? do
          state = frontier.first
          frontier.delete(state)
          log(:exploring, state)
          log_progress(state)
          problem.actions(state).each do |action|
            new_state = problem.result(action, state)
            statistics.generated += 1
            log(:action, action, new_state)
            if known.include?(new_state)
              logger.debug { "Known state" }
              next
            end
            if problem.goal?(new_state)
              return solution(new_state)
            end
            new_state.cost = heuristic.call(new_state)
            statistics.evaluated += 1
            known[new_state] = true
            frontier << new_state
          end
          statistics.expanded += 1
        end
        no_solution
      end
    end
  end
end
