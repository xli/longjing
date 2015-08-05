module Longjing
  module FF
    class Action
      attr_accessor :counter, :difficulty, :layer
      attr_reader :count_target, :action, :hash
      attr_reader :pre, :add, :del

      def initialize(action)
        @action = action
        @pre = []
        @add = []
        @del = []
        @action.precond.to_a.each do |lit|
          if lit.ff_neg_goal || !lit.is_a?(PDDL::Not)
            @pre << lit
          end
        end

        @action.effect.to_a.each do |lit|
          if lit.ff_neg_goal || !lit.is_a?(PDDL::Not)
            @add << lit
          else
            @del << lit.literal
          end
        end
        @count_target = @pre.size
        @hash = self.object_id
      end

      def signature
        @action.signature
      end

      def to_s
        "Action[#{signature}]"
      end
    end
  end
end
