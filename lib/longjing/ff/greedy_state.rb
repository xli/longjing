module Longjing
  module FF
    class GreedyState
      attr_reader :state, :dist, :hash
      def initialize(state, dist)
        @state, @dist = state, dist
        @hash = @state.hash
      end

      def ==(s)
        return true if s.object_id == self.object_id
        return false if s.nil?
        @state == s.state
      end
      alias :eql? :==

      def <=>(s)
        @dist <=> s.dist
      end
    end
  end
end
