require "longjing/version"
require 'longjing/logging'
require 'longjing/pddl'
require 'longjing/search'

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

  def pddl_plan(domain_file, problem_file, search=:ff)
    prob = pddl_problem(domain_file, problem_file)
    plan(prob, search).tap do |solution|
      validate!(prob, solution)
    end
  end

  def plan(problem, search=:ff)
    log(:problem, problem)
    Search.send(search).new.search(problem)
  end

  def validate!(prob, solution)
    raise "No solution" if solution.nil?
    goal = prob[:goal]
    actions = Hash[prob[:actions].map{|o| [o.name, o]}]
    objects = Hash[prob[:objects].map{|o| [o.name, o]}]
    state = prob[:init].to_set

    solution.each do |step|
      name, *args = step.gsub(/[()]/, ' ').strip.split(' ').map(&:to_sym)
      action = actions[name]
      args = Array(args).map{|arg| objects[arg]}
      action = action.substitute(args)
      if action.precond.applicable?(state)
        state = action.effect.apply(state)
      else
        raise "Invalid solution, failed at step: #{step.inspect}"
      end
    end
    unless goal.applicable?(state)
      raise "Invalid solution, end with #{state}"
    end
  end
end
