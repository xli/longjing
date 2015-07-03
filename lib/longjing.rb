require "longjing/version"
require 'longjing/search'
require 'longjing/problem'

module Longjing
  module_function

  def problem(data)
    Problem.new(data)
  end

  def plan(problem, strategy=:breadth_first)
    Search.new(strategy).resolve(self.problem(problem))
  end
end
