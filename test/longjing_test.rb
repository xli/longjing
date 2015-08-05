require "test_helper"

class LongjingTest < Test::Unit::TestCase
  def test_resolved_problem
    problem = cake_problem
    result = Longjing.plan(problem)
    Longjing.validate!(problem, result)
  end

  def test_search_plan
    prob = blocksworld_rand_8_problem
    result = Longjing.plan(prob)
    Longjing.validate!(prob, result)
  end

  def test_search_plan_for_typing_problem
    prob = freecell_problem
    result = Longjing.plan(prob)
    Longjing.validate!(prob, result)
  end

  def test_unresolved_problem
    Longjing.pddl(pddl_file('blocksworld-4ops'))
    problem = Longjing::PDDL.parse(<<-PDDL)
(define (problem bw-dead)
        (:domain blocksworld)
        (:objects b1 b2 b3)
        (:init (on-table b1)
               (on-table b2)
               (on-table b3)
               (clear b1)
               (clear b2)
               (clear b3)
               (arm-empty))
        (:goal (and (on b1 b2) (on b2 b3) (on b3 b1))))
PDDL
    result = Longjing.plan(problem)
    assert_nil result
  end

  def test_negative_goal
    Longjing.pddl(pddl_file('blocksworld-4ops'))
    problem = Longjing::PDDL.parse(<<-PDDL)
(define (problem bw-dead)
        (:domain blocksworld)
        (:objects b1 b2 b3 b4 b5 b6)
        (:init (on b1 b2)
               (on b2 b3)
               (on b3 b4)
               (on b4 b5)
               (on b5 b6)
               (clear b1)
               (arm-empty))
        (:goal (and (not (clear b6)) (not (on b5 b6)))))
PDDL
    result = Longjing.plan(problem)
    Longjing.validate!(problem, result)
  end

end
