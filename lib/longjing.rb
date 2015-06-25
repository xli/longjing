require "longjing/version"
require 'longjing/search'
require 'longjing/problem'

module Longjing
  module_function

  def problem(data)
    Problem.new(data)
  end

  def plan(problem)
    result = Search.new(:breadth_first).resolve(self.problem(problem))
    {
      :resolved => !result[:solution].nil?,
      :sequence => result[:solution]
    }
  end
end
