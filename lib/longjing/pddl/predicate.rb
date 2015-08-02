module Longjing
  module PDDL
    class Predicate
      attr_reader :name, :hash
      def initialize(name, vars=nil)
        @name = name
        @vars = vars || []
        @hash = name.hash
      end

      def to_s
        "(#{[name, *@vars].join(' ')})"
      end

      def inspect
        "(pred #{to_s})"
      end
    end
  end
end
