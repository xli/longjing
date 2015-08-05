require 'set'
require 'longjing/logging'

module Longjing
  module Search
    class Greedy
      include Logging

      def search(problem, h)
        log { "Greedy search" }
        initial = problem.initial
        if problem.goal?(initial)
          return final_solution(initial)
        end
        initial.cost = h.call(initial)
        logger.debug { "Initial cost:  #{initial.cost}" }
        frontier = SortedSet.new([initial])
        known = {initial => true}
        until frontier.empty? do
          state = frontier.first
          frontier.delete(state)
          log(:exploring, state, state.cost)
          problem.actions(state).each do |action|
            new_state = problem.result(action, state)
            log(:action, action, new_state)
            if known.include?(new_state)
              logger.debug { "Known state" }
              next
            end
            if problem.goal?(new_state)
              return final_solution(new_state)
            end
            new_state.cost = h.call(new_state)
            known[new_state] = true
            frontier << new_state
          end
        end
        return {}
      end

      def final_solution(state)
        {
          :solution => state.path.map(&:signature),
          :state => state.raw
        }
      end
    end
  end
end
