module Longjing
  module FF
    class Action
      attr_accessor :counter, :difficulty, :layer
      attr_reader :count_target, :pre, :add, :action, :hash

      def initialize(action)
        @action = action
        @pre = @action.precond.pos
        @add = @action.effect.pos
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
