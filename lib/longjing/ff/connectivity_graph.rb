require 'longjing/ff/action'

module Longjing
  module FF
    class ConnectivityGraph
      attr_reader :actions, :add2actions, :pre2actions, :del2actions, :literals

      def initialize(problem)
        @actions = problem.all_actions.map do |action|
          Action.new(action)
        end
        @add2actions = {}
        @pre2actions = {}
        @del2actions = {}
        @actions.each do |action|
          action.pre.each do |lit|
            @pre2actions[lit] ||= []
            @pre2actions[lit] << action
          end
          action.add.each do |lit|
            @add2actions[lit] ||= []
            @add2actions[lit] << action
          end
          action.del.each do |lit|
            @del2actions[lit] ||= {}
            @del2actions[lit][action] = true
          end
        end
        @literals = (@pre2actions.keys +
                     @add2actions.keys +
                     @del2actions.keys).uniq
      end
    end
  end
end
