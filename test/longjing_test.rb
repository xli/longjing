require "test_helper"

class LongjingTest < Test::Unit::TestCase
  def test_resolved_problem
    problem = cake_problem
    result = Longjing.plan(problem)
    assert result[:resolved]
    assert_equal [[:eat], [:bake]], result[:sequence]
  end

  def test_unresolved_problem
    problem = cake_problem
    problem[:goal] = [[:bad, :cake]]
    result = Longjing.plan(problem)
    assert !result[:resolved]
    assert_nil result[:sequence]
  end
end
