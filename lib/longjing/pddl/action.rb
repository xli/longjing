require 'longjing/pddl/literal'

module Longjing
  module PDDL
    class Action
      attr_reader :name, :params, :precond, :effect

      def initialize(name, params, precond, effect)
        @name = name
        @params = params
        @precond = precond
        @effect = effect
      end

      def substitute(arguments)
        variables = Hash[@params.zip(arguments)]
        return nil unless precond = @precond.substitute(variables)
        return nil unless effect = @effect.substitute(variables)
        Action.new(@name, arguments, precond, effect)
      end

      def signature
        "#{@name}(#{@params.map(&:name).map(&:to_s).join(' ')})"
      end

      def to_s
        "(action #{@name} :parameters #{@params.join(' ')} :precondition #{@precond} :effect #{@effect})"
      end
      alias :inspect :to_s
    end
  end
end
