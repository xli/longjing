require 'set'

module Longjing
  class Search
    class BreadthFirst
      def pop(frontier)
        min = frontier.min_by {|s| s.path.length}
        frontier.delete(min)
        min
      end

      def push(frontier, state)
        frontier << state
      end
    end

    STRATEGIES = {
      :breadth_first => BreadthFirst
    }

    def initialize(strategy)
      if !STRATEGIES.has_key?(strategy)
        raise("Unknown search strategy #{strategy.inspect}, existing strategies: #{STRATEGIES.keys.inspect}")
      end
      @strategy = STRATEGIES[strategy].new
    end

    def resolve(problem)
      frontier, explored = Set.new, Set.new
      @strategy.push(frontier, problem.initial)
      until frontier.empty? do
        state = @strategy.pop(frontier)
        explored << state

        if problem.goal?(state)
          return result(frontier, explored, state)
        end

        problem.actions(state).each do |action|
          new_state = problem.result(action, state)
          unless explored.include?(new_state) || frontier.include?(new_state)
            @strategy.push(frontier, new_state)
          end
        end
      end
      result(frontier, explored)
    end

    private
    def result(frontier, explored, state=nil)
      {
        :frontier => frontier.map(&:raw),
        :explored => explored.map(&:raw),
        :solution => state ? state.path : nil,
        :state => state ? state.raw : nil
      }
    end
  end
end
