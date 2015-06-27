require 'set'

module Longjing
  class Search
    STRATEGIES = {
      :breadth_first => lambda do |frontier, sequences|
        frontier.sort_by! do |state|
          if seq = sequences[state]
            seq.size
          else
            0
          end
        end.shift
      end
    }

    def initialize(strategy)
      @strategy = STRATEGIES[strategy] || raise("Unknown search strategy #{strategy.inspect}, existing strategies: #{STRATEGIES.keys.inspect}")
    end

    def resolve(problem)
      sequences = {}
      frontier, explored = [problem.initial], Set.new
      until frontier.empty? do
        state = @strategy[frontier, sequences]
        explored << state

        if problem.goal?(state)
          return {
            :frontier => frontier,
            :explored => explored.to_a,
            :sequences => sequences,
            :solution => Array(sequences[state]),
            :state => state
          }
        end

        problem.actions(state).each do |action|
          new_state = problem.result(action, state)
          if !explored.include?(new_state) && !frontier.include?(new_state)
            frontier << new_state
            sequence = Array(sequences[state])
            sequences[new_state] = sequence + [problem.describe(action, state)]
          end
        end
      end
      {
        :frontier => frontier,
        :explored => explored.to_a,
        :sequences => sequences
      }
    end
  end
end
