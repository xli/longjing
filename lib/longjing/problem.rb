require 'set'
require 'longjing/state'
require 'longjing/parameters'

module Longjing
  class Problem
    OPERATORS = Set.new([:-, :!=])

    attr_reader :initial

    def initialize(data)
      @types = data[:types]
      @typing = @types != nil
      @actions = data[:actions].map do |action|
        parameters = Array(action[:parameters]).map{|p| @typing ? p : [p, nil]}
        action[:parameters] = Parameters.new(parameters)
        action
      end

      @initial = State.new(data[:init].to_set)
      @goal = data[:goal].to_set
      @objects = data[:objects] ? data[:objects].to_a : nil
    end

    def goal?(state)
      @goal.all? do |lit|
        literal_negative?(lit) ? !state.include?(lit[1..-1]) : state.include?(lit)
      end
    end

    def actions(state)
      ret = []
      objs = @objects || objects(state)
      @actions.each do |action|
        action[:parameters].permutate(objs).each do |variables|
          precond = substitute_parameters(action[:precond], variables)
          if eval_precond(precond, state)
            effect = substitute_parameters(action[:effect], variables)
            arguments = action[:parameters].arguments(variables)
            describe = [action[:name]].concat(arguments)
            ret << action.merge(:effect => effect, :describe => describe)
          end
        end
      end
      ret
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

    def objects(state)
      state.raw.map(&method(:literal_objects)).flatten.uniq.map{|o| [o, nil]}
    end

    def literal_objects(lit)
      OPERATORS.include?(lit[0]) ? lit[2..-1] : lit[1..-1]
    end

    def literal_negative?(lit)
      lit[0] == :-
    end
  end
end
