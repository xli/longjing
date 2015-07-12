require "longjing/version"
require 'longjing/state'
require 'longjing/parameters'
require 'longjing/search'
require 'longjing/problem'

module Longjing
  module_function

  def state(raw, path=[])
    State.new(raw, path)
  end

  def parameters(params)
    Parameters.new(params)
  end

  def problem(data)
    Problem.new(data)
  end

  def plan(problem, strategy=:breadth_first)
    Search.new(strategy).resolve(self.problem(problem))
  end

  def validate!(problem, solution)
    raise "No solution" if solution.nil?
    problem = problem.to_h
    goal = problem[:goal]
    actions = problem[:actions].inject({}) do |memo, action|
      memo[action.describe] = action
      memo
    end
    state = problem[:initial]
    solution.each do |step|
      action = actions[step]
      if action.executable?(state)
        state = action.result(state)
      else
        raise "Invalid solution, failed at: #{step.inspect}"
      end
    end
    unless goal.match?(state)
      raise "Invalid solution, end with #{state}"
    end
  end
end
