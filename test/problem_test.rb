require "test_helper"

class ProblemTest < Test::Unit::TestCase
  def test_initial
    prob = Longjing.problem(cake_problem)
    assert_equal state([[:have, :cake]]), prob.initial
  end

  def test_goal_test
    prob = Longjing.problem(cake_problem)
    assert prob.goal?([[:have, :cake], [:eaten, :cake]].to_set)
    assert prob.goal?([[:eaten, :cake], [:have, :cake]].to_set)
    assert prob.goal?([[:have, :cake], [:eaten, :cake], [:something, :else]].to_set)
    assert !prob.goal?([[:eaten, :cake]].to_set)
    assert !prob.goal?([[:have, :cake]].to_set)

    prob = Longjing.problem(cake_problem.
                             merge(goal: [[:-, :have, :cake]]))
    assert prob.goal?([].to_set)
  end

  def test_actions
    prob = Longjing.problem(cake_problem)
    actions = prob.actions(state([[:have, :cake]]))
    assert_equal 1, actions.size
    assert_equal :eat, actions[0][:name]

    actions = prob.actions(state([[:eaten, :cake]]))
    assert_equal 1, actions.size
    assert_equal :bake, actions[0][:name]
  end

  def test_result
    prob = Longjing.problem(cake_problem)
    state = state([[:have, :cake]])
    actions = prob.actions(state)
    ret = prob.result(actions[0], state)
    assert_equal state([[:eaten, :cake]]), ret
  end

  def test_actions_with_arguments
    prob = Longjing.problem(blocks_world_problem)
    actions = prob.actions(prob.initial)

    assert_equal 4, actions.size
    assert_equal :move, actions[0][:name]
    assert_equal [:B, :table, :C], actions[0][:arg_values]

    assert_equal :move, actions[1][:name]
    assert_equal [:C, :A, :B], actions[1][:arg_values]

    assert_equal :moveToTable, actions[2][:name]
    assert_equal [:B, :table], actions[2][:arg_values]

    assert_equal :moveToTable, actions[3][:name]
    assert_equal [:C, :A], actions[3][:arg_values]
  end

  def test_result_with_arguments
    prob = Longjing.problem(blocks_world_problem)
    actions = prob.actions(prob.initial)
    result = prob.result(actions[0], prob.initial)
    expected = [[:on, :A, :table],
                [:on, :B, :C],
                [:on, :C, :A],
                [:block, :A],
                [:block, :B],
                [:block, :C],
                [:clear, :table],
                [:clear, :B]]
    assert_equal state(expected), result
  end

  def state(raw)
    Longjing.state(raw.to_set)
  end
end
