require 'longjing/state'
require 'longjing/parameters'
require 'longjing/literal'
require 'longjing/action'

module Longjing
  class Problem
    attr_reader :initial, :goal, :ground_actions

    def initialize(data)
      @objects = data[:objects]
      @ground_actions = data[:actions].map do |action|
        params = Parameters.new(action[:parameters], data[:types])
        params.propositionalize(action, @objects).map{|h| Action.new(h)}
      end.flatten
      @initial = State.new(Literal.set(data[:init]))
      @goal = Literal.list(data[:goal])

      @data = data
    end

    def goal?(state)
      @goal.match?(state.raw)
    end

    def actions(state)
      @ground_actions.select do |action|
        action.precond.match?(state.raw)
      end
    end

    def result(action, state)
      raw = action.effect.apply(state.raw)
      State.new(raw, state.path + [action])
    end

    def describe
      %{Problem: #{@data[:problem] || 'Unknown'}
Domain: #{@data[:domain] || 'Unknown'}
Requirements: #{Array(@data[:requirements]).join(', ')}
Types: #{@data[:types].inspect}
Initial: #{@initial}
Goal: #{@goal}
#{stats}
}
    end

    def stats
%{
# types: #{Array(@data[:types]).size}
# predicates: #{@data[:predicates] ? @data[:predicates].size : 'Unknown'}
# actions: #{@data[:actions].size}
# object: #{@objects.size}
# ground actions: #{@ground_actions.size}
}
    end
  end
end
