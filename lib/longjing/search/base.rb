require 'longjing/logging'

module Longjing
  module Search
    class Base
      include Logging

      def solution(state)
        state.path.map(&:signature)
      end

      def no_solution
      end
    end
  end
end
