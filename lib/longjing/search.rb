require 'set'

module Longjing
  class Search

    class State
      attr_reader :raw, :path, :hash
      def initialize(raw, path=[])
        @raw = raw
        @path = path
        @hash = @raw.hash
      end

      def ==(state)
        state && @raw == state.raw
      end
      alias :eql? :==
    end

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
      @strategy.push(frontier, State.new(problem.initial))
      until frontier.empty? do
        state = @strategy.pop(frontier)
        explored << state

        if problem.goal?(state.raw)
          return result(frontier, explored, state)
        end

        problem.actions(state.raw).each do |action|
          new_raw = problem.result(action, state.raw)
          new_event = problem.describe(action, state.raw)
          new_state = State.new(new_raw, state.path + [new_event])
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
