require "test_helper"

class ProblemsTest < Test::Unit::TestCase

  def test_blocks_world_problem
    assert_planning_solution blocks_world_problem
  end

  def test_cake_problem
    assert_planning_solution cake_problem
  end

  def test_cargo_transportation_problem
    assert_planning_solution cargo_transportation_problem
  end

  def assert_planning_solution(problem)
    result = Longjing.plan(problem)
    assert result[:resolved]
    assert_equal problem[:solution], result[:sequence]
  end
end