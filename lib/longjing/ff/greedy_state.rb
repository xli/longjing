module Longjing
  module FF
    class GreedyState
      attr_reader :state, :dist, :hash
      def initialize(state, dist)
        @state, @dist = state, dist
        @hash = @state.hash
      end

      def ==(s)
        s && @state == s.state
      end
      alias :eql? :==

      def <=>(s)
        @dist <=> s.dist
      end
    end
  end
end
