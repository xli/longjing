require "longjing/version"
require 'longjing/logging'
require 'longjing/state'
require 'longjing/parameters'
require 'longjing/ff'
require 'longjing/problem'
require 'longjing/pddl'

module Longjing
  extend Logging

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
    data.is_a?(Problem) ? data : Problem.new(data)
  end

  def pddl_plan(domain, problem)
    PDDL.parse(File.read(domain))
    pddl = PDDL.parse(File.read(problem))
    prob = Longjing.problem(pddl)
    result = Longjing.plan(prob)
    Longjing.validate!(prob, result[:solution])
    log(:solution, result[:solution])
  end

  def plan(problem)
    FF::Search.new.resolve(self.problem(problem))
  end

  def validate!(prob, solution)
    raise "No solution" if solution.nil?
    goal = prob.goal
    actions = prob.ground_actions.inject({}) do |memo, action|
      memo[action.describe] = action
      memo
    end
    state = prob.initial
    solution.each do |step|
      action = actions[step]
      if action.precond.match?(state.raw)
        state = prob.result(action, state)
      else
        raise "Invalid solution, failed at step: #{step.inspect}"
      end
    end
    unless goal.match?(state)
      raise "Invalid solution, end with #{state}"
    end
  end
end
