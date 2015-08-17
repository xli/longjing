require "longjing/version"
require 'longjing/logging'
require 'longjing/pddl'
require 'longjing/search'

module Longjing
  extend Logging

  class Fail < StandardError
  end

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
    solution = plan(prob, search)

    prob = pddl_problem(domain_file, problem_file)
    validate!(prob, solution)

    solution
  rescue Fail
    exit(1)
  end

  def plan(problem, search=:ff)
    log(:problem, problem)
    Search.send(search).new.search(problem)
  end

  def validate!(prob, solution)
    if solution.nil?
      raise Fail, "No solution"
    end
    goal = prob[:goal]
    actions = Hash[prob[:actions].map{|o| [o.name, o]}]
    objects = Hash[(Array(prob[:constants]) +
                    Array(prob[:objects])).map{|o| [o.name, o]}]
    state = prob[:init].to_set

    solution.each do |step|
      name, *args = step.gsub(/[()]/, ' ').strip.split(' ').map(&:to_sym)
      action = actions[name]
      args = Array(args).map{|arg| objects[arg]}
      action = action.substitute(args)
      if action.precond.applicable?(state)
        state = action.effect.apply(state)
      else
        log { "================================" }
        log { "Invalid solution:" }
        log { "Failed at step: #{step}" }
        log { "action: #{action.name}" }
        log { "  precond: #{action.precond}" }
        log { "is not applicable to state: " }
        log(:facts, state.to_a)
        raise Fail, "Invalid solution"
      end
    end
    unless goal.applicable?(state)
      log { "Invalid solution, end with #{state}" }
      raise Fail, "Invalid solution"
    end
  end
end
