require "test_helper"

class ProblemTest < Test::Unit::TestCase
  def test_initial
    prob = Longjing.problem(cake_problem)
    assert_equal [[:have, :cake]], prob.initial
  end

  def test_goal_test
    prob = Longjing.problem(cake_problem)
    assert prob.goal?([[:have, :cake], [:eaten, :cake]])
    assert prob.goal?([[:eaten, :cake], [:have, :cake]])
    assert !prob.goal?([[:eaten, :cake]])
    assert !prob.goal?([[:have, :cake]])
  end

  def test_actions
    prob = Longjing.problem(cake_problem)
    actions = prob.actions([[:have, :cake]])
    assert_equal 1, actions.size
    assert_equal :eat, actions[0][:name]

    actions = prob.actions([[:eaten, :cake]])
    assert_equal 1, actions.size
    assert_equal :bake, actions[0][:name]
  end

  def test_result
    prob = Longjing.problem(cake_problem)
    state = [[:have, :cake]]
    actions = prob.actions(state)
    ret = prob.result(actions[0], state)
    assert_equal [[:eaten, :cake]], ret
  end

  def test_describe
    prob = Longjing.problem(cake_problem)
    state = [[:have, :cake]]
    actions = prob.actions(state)
    assert_equal [:eat], prob.describe(actions[0], state)
  end
end
