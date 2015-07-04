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
end
