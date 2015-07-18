require "longjing/version"
require 'longjing/state'
require 'longjing/parameters'
require 'longjing/ff'
require 'longjing/problem'
require 'longjing/pddl'

module Longjing
  module_function
  def load(pddl)
    PDDL.parse(File.read(pddl))
  end

  def state(raw, path=[])
    State.new(raw, path)
  end

  def parameters(params, types=nil)
    Parameters.new(params, types)
  end

  def problem(data)
    Problem.new(data)
  end

  def plan(problem)
    FF::Search.new.resolve(self.problem(problem))
  end

  def validate!(problem, solution)
    raise "No solution" if solution.nil?
    prob = problem.to_h
    goal = prob[:goal]
    actions = prob[:actions].inject({}) do |memo, action|
      memo[action.describe] = action
      memo
    end
    state = prob[:initial]
    solution.each do |step|
      action = actions[step]
      if action.precond.match?(state.raw)
        state = problem.result(action, state)
      else
        raise "Invalid solution, failed at step: #{step.inspect}"
      end
    end
    unless goal.match?(state)
      raise "Invalid solution, end with #{state}"
    end
  end
end
