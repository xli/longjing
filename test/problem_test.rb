require "test_helper"

class ProblemTest < Test::Unit::TestCase
  def test_initial
    prob = Longjing.problem(cake_problem)
    assert_equal state([[:have, :cake]]), prob.initial
  end

  def test_goal_test
    prob = Longjing.problem(cake_problem)
    assert prob.goal?(state([[:have, :cake], [:eaten, :cake]]))
    assert prob.goal?(state([[:eaten, :cake], [:have, :cake]]))
    assert prob.goal?(state([[:have, :cake], [:eaten, :cake], [:something, :else]]))
    assert !prob.goal?(state([[:eaten, :cake]]))
    assert !prob.goal?(state([[:have, :cake]]))

    prob = Longjing.problem(cake_problem.
                             merge(goal: [[:-, :have, :cake]]))
    assert prob.goal?(state([]))
  end

  def test_actions
    prob = Longjing.problem(cake_problem)
    actions = prob.actions(state([[:have, :cake]]))
    assert_equal 1, actions.size
    assert_equal :eat, actions[0].name

    actions = prob.actions(state([[:eaten, :cake]]))
    assert_equal 1, actions.size
    assert_equal :bake, actions[0].name
  end

  def test_result
    prob = Longjing.problem(cake_problem)
    state = state([[:have, :cake]])
    actions = prob.actions(state)
    ret = prob.result(actions[0], state)
    assert_equal state([[:eaten, :cake]]), ret
  end

  def test_actions_with_parameters
    prob = Longjing.problem(blocks_world_problem)
    actions = prob.actions(prob.initial)

    assert_equal 3, actions.size
    assert_equal :move, actions[0].name
    assert_equal [[:on, :B, :C],
                  [:clear, :table],
                  [:-, :on, :B, :table],
                  [:-, :clear, :C]], actions[0].effect.to_a.map(&:raw)
    assert_equal "move(B table C)", actions[0].describe

    assert_equal :move, actions[1].name
    assert_equal [[:on, :C, :B],
                  [:clear, :A],
                  [:-, :on, :C, :A],
                  [:-, :clear, :B]], actions[1].effect.to_a.map(&:raw)
    assert_equal "move(C A B)", actions[1].describe

    assert_equal :moveToTable, actions[2].name
    assert_equal [[:on, :C, :table],
                  [:clear, :A],
                  [:-, :on, :C, :A]], actions[2].effect.to_a.map(&:raw)
    assert_equal "moveToTable(C A)", actions[2].describe
  end

  def test_result_with_parameters
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

  def test_support_typing
    prob = Longjing.problem(cargo_transportation_problem)
    actions = prob.actions(prob.initial)
    assert_equal 4, actions.size
    assert_equal ['load(c1 p1 sfo)', 'load(c2 p2 jfk)',
                  'fly(p1 sfo jfk)', 'fly(p2 jfk sfo)'], actions.map(&:describe)
    result = prob.result(actions[0], prob.initial)
    expected = [[:at, :c2, :jfk],
                [:at, :p1, :sfo],
                [:at, :p2, :jfk],
                [:in, :c1, :p1]]
    assert_equal state(expected), result
  end

  def state(raw)
    Longjing.state(Longjing::Literal.set(raw))
  end
end
