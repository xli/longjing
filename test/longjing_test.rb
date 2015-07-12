require "test_helper"

class LongjingTest < Test::Unit::TestCase
  def test_resolved_problem
    problem = cake_problem
    result = Longjing.plan(problem)
    assert result[:solution]
    assert result[:state]
    Longjing.validate!(Longjing.problem(problem), result[:solution])
  end

  def test_unresolved_problem
    problem = cake_problem
    problem[:goal] = [[:bad, :cake]]
    result = Longjing.plan(problem)
    assert_nil result[:solution]
    assert_nil result[:state]
  end
end
