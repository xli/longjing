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
  def pddl(file)
    raise "File #{file.inspect} does not exist" unless File.exist?(file)
    PDDL.parse(File.read(file))
  end

  def pddl_problem(domain_file, problem_file)
    pddl(domain_file)
    pddl(problem_file)
  end

  def pddl_plan(domain_file, problem_file)
    prob = problem(pddl_problem(domain_file, problem_file))
    result = plan(prob)
    Longjing.validate!(prob, result[:solution])
    log(:solution, result[:solution])
  end

  def problem(data)
    data.is_a?(Problem) ? data : Problem.new(data)
  end

  def plan(problem)
    FF::Search.new.resolve(self.problem(problem))
  end

  def validate!(prob, solution)
    raise "No solution" if solution.nil?
    goal = prob.goal
    actions = prob.ground_actions.inject({}) do |memo, action|
      memo[action.signature] = action
      memo
    end
    state = prob.initial
    solution.each do |step|
      action = actions[step]
      if action.precond.applicable?(state.raw)
        state = prob.result(action, state)
      else
        raise "Invalid solution, failed at step: #{step.inspect}"
      end
    end
    unless goal.applicable?(state.raw)
      raise "Invalid solution, end with #{state}"
    end
  end
end
