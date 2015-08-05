require 'longjing/logging'

module Longjing
  module Search
    class Base
      include Logging

      def solution(state)
        {
          :solution => state.path.map(&:signature),
          :state => state.raw
        }
      end

      def no_solution
        {}
      end
    end
  end
end
