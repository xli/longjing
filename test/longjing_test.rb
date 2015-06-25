require "test_helper"

class LongjingTest < Test::Unit::TestCase
  def test_blocks_world_planning
    problem = blocks_world_problem
    result = Longjing.plan(problem)

    assert result[:resolved]
    assert_equal [[:moveToTable, :C, :A], [:move, :B, :table, :C], [:move, :table, :B]], result[:sequence]
  end

  def test_cake_example_planning
    problem = cake_problem
    result = Longjing.plan(problem)
    assert result[:resolved]
    assert_equal [[:eat], [:bake]], result[:sequence]
  end
end
