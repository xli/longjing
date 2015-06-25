module Longjing
  class Problem
    attr_reader :initial

    def initialize(data)
      @initial = data[:init]
      @goal = data[:goal].sort
      @actions = data[:actions]
    end

    def goal?(state)
      @goal == state.sort
    end

    def actions(state)
      @actions.select do |action|
        action[:precond].all? do |cond|
          case cond[0]
          when :-
            !state.include?(cond[1..-1])
          else
            state.include?(cond)
          end
        end
      end
    end

    def result(action, state)
      action[:effect].inject(state) do |memo, effect|
        case effect[0]
        when :-
          memo - [effect[1..-1]]
        else
          memo + [effect]
        end
      end
    end

    def describe(action, state)
      [action[:name]]
    end
  end
end
