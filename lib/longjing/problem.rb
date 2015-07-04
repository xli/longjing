require 'set'
require 'longjing/state'
require 'longjing/parameters'

module Longjing
  class Problem
    OPERATORS = Set.new([:-, :!=])

    attr_reader :initial, :objects

    def initialize(data)
      @types = data[:types]
      @typing = @types != nil ? lambda {|o| o} : lambda {|o| [o, nil]}
      @objects = data[:objects].map(&@typing)
      @actions = data[:actions].map do |action|
        parameters = Parameters.new(Array(action[:parameters]).map(&@typing))
        parameters.permutate(@objects).map do |variables|
          precond = substitute_parameters(action[:precond], variables)
          effect = substitute_parameters(action[:effect], variables)
          arguments = parameters.arguments(variables)
          describe = [action[:name]].concat(arguments)
          action.merge(:precond => precond,
                       :effect => effect,
                       :describe => describe)
        end
      end.flatten

      @initial = State.new(data[:init].to_set)
      @goal = data[:goal].to_set
    end

    def goal?(state)
      @goal.all? do |lit|
        literal_negative?(lit) ? !state.include?(lit[1..-1]) : state.include?(lit)
      end
    end

    def actions(state)
      @actions.select do |action|
        eval_precond(action[:precond], state)
      end
    end

    def result(action, state)
      raw = action[:effect].inject(state.raw.dup) do |memo, effect|
        case effect[0]
        when :-
          memo.delete(effect[1..-1])
        else
          memo << effect
        end
      end
      State.new(raw, state.path + [action[:describe]])
    end

    private
    def substitute_parameters(exps, args)
      exps.map do |exp|
        exp.map { |e| args[e] || e }
      end
    end

    def eval_precond(precond, state)
      precond.all? do |cond|
        case cond[0]
        when :-
          !state.include?(cond[1..-1])
        when :!=
          cond[1] != cond[2]
        else
          state.include?(cond)
        end
      end
    end

    def literal_negative?(lit)
      lit[0] == :-
    end
  end
end
