module Longjing
  module PDDL
    class Type
      attr_reader :name, :parent, :hash
      def initialize(name, parent=nil)
        @name = name
        @parent = if name != :object
                    parent || Type::OBJECT
                  end
        @hash = name.hash
      end

      def to_s
        @parent ? "#{@name} - #{@parent}" : @name.to_s
      end

      def inspect
        "(type #{to_s})"
      end

      OBJECT = Type.new(:object)
    end
  end
end
