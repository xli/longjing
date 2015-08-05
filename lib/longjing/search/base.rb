require 'longjing/logging'
require 'longjing/search/statistics'

module Longjing
  module Search
    class Base
      include Logging

      attr_reader :statistics

      def initialize
        @t = Time.now
        @statistics = Statistics.new
        reset_best_heuristic
      end

      def reset_best_heuristic
        @best = Float::INFINITY
      end

      def log_progress(state)
        return if @best <= state.cost
        @best = state.cost
        log {
          msg = [
            "#{statistics.generated} generated",
            "#{statistics.evaluated} evaluated",
            "#{statistics.expanded} expanded",
            "h=#{@best}",
            "#{state.path.size} steps",
            "t=#{Time.now - @t}"
          ].join(', ')
        }
      end

      def log_solution(steps)
        log { "Solution found!" }
        log { "Actual search time: #{Time.now - @t}" }
        log { "Plan length: #{steps.size} step(s)." }
        log { "Expanded #{statistics.expanded} state(s)." }
        log { "Evaluated #{statistics.evaluated} state(s)." }
        log { "Generated #{statistics.generated} state(s)." }
        log { "Solution:" }
        steps.each_with_index do |step, i|
          log { "#{i}. #{step}" }
        end
      end

      def solution(state)
        state.path.map(&:signature).tap(&method(:log_solution))
      end

      def no_solution
        log { "No solution found!" }
        nil
      end
    end
  end
end
