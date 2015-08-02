module Longjing
  module PDDL
    class Var
      attr_reader :name, :type, :hash
      def initialize(name, type=nil)
        @name = name
        @type = type || Type::OBJECT
        @hash = name.hash
      end

      def to_s
        "#{@name} - #{@type}"
      end

      def inspect
        "(var #{to_s})"
      end
    end
  end
end
