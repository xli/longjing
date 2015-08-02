module Longjing
  module PDDL
    class Obj
      attr_reader :name, :type, :hash
      def initialize(name, type=nil)
        @name = name
        @type = type || Type::OBJECT
        @hash = name.hash
      end

      def is_a?(type)
        t = @type
        t = t.parent until t == type || t.nil?
        !t.nil?
      end

      def to_s
        "#{@name} - #{@type}"
      end

      def inspect
        "(object #{to_s})"
      end
    end
  end
end
