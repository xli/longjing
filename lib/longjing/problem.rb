require 'set'

module Longjing
  class Problem
    OPERATORS = Set.new([:-, :!=])

    attr_reader :initial

    def initialize(data)
      @initial = data[:init].to_set
      @goal = data[:goal].to_set
      @actions = data[:actions]
    end

    def goal?(state)
      @goal.all? do |s|
        s[0] == :- ? !state.include?(s[1..-1]) : state.include?(s)
      end
    end

    def actions(state)
      @actions.map do |action|
        arg_names = Array(action[:arguments])
        objects(state).repeated_permutation(arg_names.size).select do |arg_values|
          precond = substitute_arguments(:precond, action, arg_values)
          eval_precond(state, precond)
        end.map do |arg_values|
          action.merge(:arg_values => arg_values)
        end
      end.flatten
    end

    def result(action, state)
      substitute_arguments(:effect, action, action[:arg_values]).inject(state.dup) do |memo, effect|
        case effect[0]
        when :-
          memo.delete(effect[1..-1])
        else
          memo << effect
        end
      end
    end

    def describe(action, state)
      [action[:name]].concat(action[:arg_values])
    end

    private
    def substitute_arguments(attr, action, arg_values)
      return action[attr] if action[:arguments].nil?
      args = Hash[action[:arguments].zip(arg_values)]
      action[attr].map do |exp|
        exp.map { |e| args[e] || e }
      end
    end

    def objects(state)
      state.map do |s|
        start = operator?(s[0]) ? 2 : 1
        s[start..-1]
      end.flatten.uniq
    end

    def operator?(c)
      OPERATORS.include?(c)
    end

    def eval_precond(state, precond)
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
  end
end
