require 'set'
require 'longjing/state'
require 'longjing/parameters'

module Longjing
  class Problem
    attr_reader :initial, :goal, :ground_actions

    def initialize(data)
      @objects = data[:objects]
      @ground_actions = data[:actions].map do |action|
        params = Parameters.new(action)
        params.propositionalize(@objects)
      end.flatten
      @initial = State.new(data[:init].to_set)
      @goal = data[:goal]

      @data = data
    end

    def goal?(state)
      @goal.applicable?(state.raw)
    end

    def actions(state)
      @ground_actions.select do |action|
        action.precond.applicable?(state.raw)
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
Types: #{@data[:types]}
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
