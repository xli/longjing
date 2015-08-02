require "test_helper"

class ProblemTest < Test::Unit::TestCase
  def test_interface
    prob = Longjing.problem(cake_problem)
    assert !prob.goal?(prob.initial)

    eat = prob.actions(prob.initial)[0]
    assert_equal 'eat()', eat.signature
    eaten_state = prob.result(eat, prob.initial)
    assert !prob.goal?(eaten_state)

    bake = prob.actions(eaten_state)[0]
    assert_equal 'bake()', bake.signature
    baked_state = prob.result(bake, eaten_state)

    assert prob.goal?(baked_state)
  end
end
