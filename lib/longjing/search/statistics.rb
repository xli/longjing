module Longjing
  module Search
    class Statistics
      attr_accessor :generated, :expanded, :evaluated
      def initialize
        @generated, @expanded, @evaluated = 0, 0, 0
      end
    end
  end
end
