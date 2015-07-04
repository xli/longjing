require 'set'
require 'longjing/state'

module Longjing
  class Problem
    OPERATORS = Set.new([:-, :!=])

    attr_reader :initial

    def initialize(data)
      @initial = State.new(data[:init].to_set)
      @goal = data[:goal].to_set
      @actions = data[:actions]
    end

    def goal?(state)
      @goal.all? do |lit|
        literal_negative?(lit) ? !state.include?(lit[1..-1]) : state.include?(lit)
      end
    end

    def actions(state)
      @actions.map do |action|
        arg_names = Array(action[:arguments])
        objects(state).permutation(arg_names.size).select do |arg_values|
          precond = substitute_arguments(:precond, action, arg_values)
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
        end.map do |arg_values|
          action.merge(:arg_values => arg_values)
        end
      end.flatten
    end

    def result(action, state)
      raw = substitute_arguments(:effect, action, action[:arg_values]).inject(state.raw.clone) do |memo, effect|
        case effect[0]
        when :-
          memo.delete(effect[1..-1])
        else
          memo << effect
        end
      end
      State.new(raw, state.path + [self.describe(action)])
    end

    def describe(action)
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
      state.raw.map(&method(:literal_objects)).flatten.uniq
    end

    def literal_objects(lit)
      OPERATORS.include?(lit[0]) ? lit[2..-1] : lit[1..-1]
    end

    def literal_negative?(lit)
      lit[0] == :-
    end
  end
end
