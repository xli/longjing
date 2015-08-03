require 'set'
require 'longjing/state'

module Longjing
  class Problem
    attr_reader :initial, :goal, :all_actions

    def initialize(actions, init, goal)
      @all_actions = actions
      @initial = State.new(init.to_set)
      @goal = goal
    end

    def goal?(state)
      @goal.applicable?(state.raw)
    end

    def actions(state)
      @all_actions.select do |action|
        action.precond.applicable?(state.raw)
      end
    end

    def result(action, state)
      raw = action.effect.apply(state.raw)
      State.new(raw, state.path + [action])
    end
  end
end
