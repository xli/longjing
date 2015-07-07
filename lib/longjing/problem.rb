require 'set'
require 'longjing/state'
require 'longjing/parameters'
require 'longjing/literal'

module Longjing
  class Problem
    attr_reader :initial

    def initialize(data)
      typing = data[:types] != nil ? lambda {|o| o} : lambda {|o| [o, nil]}
      @objects = data[:objects].map(&typing)
      @actions = data[:actions].map do |action|
        params = Parameters.new(Array(action[:parameters]).map(&typing))
        params.propositionalize(action, @objects)
      end.flatten
      @initial = State.new(Literal.set(data[:init]))
      @goal = data[:goal].map{|lit| Literal.new(lit)}
    end

    def to_h
      {
        :goal => @goal,
        :initial => @initial,
        :actions => @actions,
        :objects => @objects
      }
    end

    def goal?(state)
      @goal.all? do |lit|
        lit.negative? ? !state.include?(lit.positive) : state.include?(lit)
      end
    end

    def actions(state)
      @actions.select do |action|
        action[:precond].all? do |cond|
          if cond.negative?
            !state.include?(cond.positive)
          else
            state.include?(cond)
          end
        end
      end
    end

    def result(action, state)
      raw = action[:effect].inject(state.raw.dup) do |memo, effect|
        if effect.negative?
          memo.delete(effect.positive)
        else
          memo << effect
        end
      end
      State.new(raw, state.path + [action[:describe]])
    end
  end
end
