require 'longjing/parameters'
require 'longjing/problem'

module Longjing
  module FF
    class Preprocess
      module NegGoal
        def applicable?(set)
          set.include?(self)
        end
        def apply(set)
          set << self
        end
      end

      def execute(problem)
        ret = propositionalize(problem)
        reverse_negative_goals(ret.goal)
        ret
      end

      def propositionalize(problem)
        actions = problem[:actions].map do |action|
          params = Parameters.new(action)
          params.propositionalize(problem[:objects])
        end.flatten
        Problem.new(actions, problem[:init], problem[:goal])
      end

      def reverse_negative_goals(goal)
        case goal
        when PDDL::And
          goal.literals.each do |lit|
            reverse_negative_goals(lit)
          end
        when PDDL::Not
          goal.extend(NegGoal)
          goal.ff_neg_goal = true
        end
      end
    end
  end
end
