require 'set'
require 'longjing/state'
require 'longjing/parameters'
require 'longjing/literal'

module Longjing
  class Problem
    attr_reader :initial, :objects

    def initialize(data)
      @types = data[:types]
      @typing = @types != nil ? lambda {|o| o} : lambda {|o| [o, nil]}
      @objects = data[:objects].map(&@typing)
      @actions = data[:actions].map do |action|
        parameters = Parameters.new(Array(action[:parameters]).map(&@typing))
        parameters.permutate(@objects).map do |variables|
          precond = substitute_variables(action[:precond], variables)
          effect = substitute_variables(action[:effect], variables)
          arguments = parameters.arguments(variables)
          describe = [action[:name]].concat(arguments)
          action.merge(:precond => precond,
                       :effect => effect,
                       :describe => describe)
        end
      end.flatten

      @initial = State.new(Literal.set(data[:init]))
      @goal = Literal.set(data[:goal])
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
          elsif cond.inequal?
            cond.match?
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

    private
    def substitute_variables(exps, args)
      exps.map do |exp|
        Literal.new(exp.map { |e| args[e] || e })
      end
    end
  end
end
