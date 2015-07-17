require 'set'
require 'longjing/state'
require 'longjing/parameters'
require 'longjing/literal'
require 'longjing/action'

module Longjing
  class Problem
    attr_reader :initial

    def initialize(data)
      @objects = data[:objects]
      @actions = data[:actions].map do |action|
        params = Parameters.new(action[:parameters], data[:types])
        params.propositionalize(action, @objects).map{|h| Action.new(h)}
      end.flatten
      @initial = State.new(Literal.set(data[:init]))
      @goal = Literal.list(data[:goal])
    end

    def to_h
      {
        :goal => @goal,
        :initial => @initial,
        :actions => @actions
      }
    end

    def goal?(state)
      @goal.match?(state.raw)
    end

    def actions(state)
      @actions.select do |action|
        action.executable?(state)
      end
    end

    def result(action, state)
      action.result(state)
    end
  end
end
