require 'set'
require 'longjing/search/base'
require 'longjing/ff/preprocess'
require 'longjing/ff/connectivity_graph'
require 'longjing/ff/ordering'
require 'longjing/ff/relaxed_graph_plan'

module Longjing
  module PDDL
    class Literal
      attr_accessor :ff_neg_goal
    end
  end

  module Search
    def self.ff_greedy
      FFGreedy
    end

    class FFGreedy < FF
      def search(problem)
        log { 'FF greedy search starts' }
        init(problem)
        greedy_search
      end
    end
  end
end
