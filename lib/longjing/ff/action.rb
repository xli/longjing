module Longjing
  module FF
    class Action
      attr_accessor :counter, :difficulty, :layer
      attr_reader :count_target, :action, :hash
      attr_reader :pre, :add, :del

      def initialize(action)
        @action = action
        @pre = @action.precond.pos
        @add = @action.effect.pos
        @del = @action.effect.neg
        @count_target = @pre.size
        @hash = self.object_id
      end

      def describe
        @action.describe
      end

      def to_s
        "Action[#{describe}]"
      end
    end
  end
end
