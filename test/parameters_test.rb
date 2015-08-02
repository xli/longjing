require "test_helper"

class ParametersTest < Test::Unit::TestCase
  include Longjing

  def test_permutate_two_params_without_typing
    PDDL.parse(<<-PDDL)
(define (domain cargo)
  (:predicates (at ?c ?a)
               (in ?c ?p))
  (:action fly
      :parameters (?p ?to)
      :precondition ()
      :effect (at ?p ?to)))
PDDL
    problem = PDDL.parse(<<-PDDL)
(define (problem cargo-a) (:domain cargo)
  (:objects p1 p2 sfo jfk)
  (:init (at p1 jfk))
  (:goal (at p1 sfo)))
PDDL
    fly = problem[:actions][0]

    params = Parameters.new(fly)
    p1, p2, sfo, jfk = problem[:objects]
    variables = params.permutate(problem[:objects])
    assert_equal 4*4, variables.size
    expected = [
      [p1,  p1],
      [p1,  p2],
      [p1,  sfo],
      [p1,  jfk],
      [p2,  p1],
      [p2,  p2],
      [p2,  sfo],
      [p2,  jfk],
      [sfo, p1],
      [sfo, p2],
      [sfo, sfo],
      [sfo, jfk],
      [jfk, p1],
      [jfk, p2],
      [jfk, sfo],
      [jfk, jfk]
    ]
    assert_equal expected, variables
  end

  def test_permutate_empty_params
    PDDL.parse(<<-PDDL)
(define (domain cake)
  (:predicates (eaten))
  (:action eat
      :parameters ()
      :precondition ()
      :effect (eaten)))
PDDL
    problem = PDDL.parse(<<-PDDL)
(define (problem cake-a) (:domain cake)
  (:objects cake1 cake2)
  (:init)
  (:goal (eaten)))
PDDL
    eat = problem[:actions][0]
    params = Parameters.new(eat)
    assert_equal [], params.permutate(problem[:objects])
  end

  def test_permutate_dup_types_params
    PDDL.parse(<<-PDDL)
(define (domain cargo)
  (:types cargo plane airport)
  (:predicates (at ?p - plane ?a - airport)
               (in ?c - cargo ?p - plane))
  (:action fly
      :parameters (?p - plane ?from - airport ?to - airport)
      :precondition (at ?p ?from)
      :effect (and (not (at ?p ?from)) (at ?p ?to))))
PDDL
    problem = PDDL.parse(<<-PDDL)
(define (problem cargo-a) (:domain cargo)
  (:objects p1 p2 - plane sfo jfk - airport)
  (:init (at p1 jfk))
  (:goal (at p1 sfo)))
PDDL
    fly = problem[:actions][0]

    params = Parameters.new(fly)
    p1, p2, sfo, jfk = problem[:objects]
    variables = params.permutate(problem[:objects])

    assert_equal 2*2*2, variables.size
    expected = [
      [p1, sfo, sfo],
      [p1, sfo, jfk],
      [p1, jfk, sfo],
      [p1, jfk, jfk],
      [p2, sfo, sfo],
      [p2, sfo, jfk],
      [p2, jfk, sfo],
      [p2, jfk, jfk]
    ]

    assert_equal expected, variables
  end

  def test_permutate_four_params
    PDDL.parse(<<-PDDL)
(define (domain cargo)
  (:types cargo plane airport)
  (:predicates (at ?p - plane ?a - airport)
               (in ?c - cargo ?p - plane))
  (:action fly
      :parameters (?p - plane ?c - cargo ?from - airport ?to - airport)
      :precondition (at ?p ?from)
      :effect (and (not (at ?p ?from)) (at ?p ?to))))
PDDL
    problem = PDDL.parse(<<-PDDL)
(define (problem cargo-a) (:domain cargo)
  (:objects p1 p2 - plane sfo jfk kfc - airport c1 c2 c3 c4 - cargo)
  (:init (at p1 jfk))
  (:goal (at p1 sfo)))
PDDL
    fly = problem[:actions][0]

    params = Parameters.new(fly)
    p1, p2, sfo, jfk, kfc, c1, c2, c3, c4 = problem[:objects]
    variables = params.permutate(problem[:objects])

    assert_equal 2*4*3*3, variables.size
    expected = [[p1, c1, sfo, sfo],
                [p1, c1, sfo, jfk],
                [p1, c1, sfo, kfc],
                [p1, c1, jfk, sfo],
                [p1, c1, jfk, jfk],
                [p1, c1, jfk, kfc],
                [p1, c1, kfc, sfo],
                [p1, c1, kfc, jfk],
                [p1, c1, kfc, kfc],
                [p1, c2, sfo, sfo],
                [p1, c2, sfo, jfk],
                [p1, c2, sfo, kfc],
                [p1, c2, jfk, sfo],
                [p1, c2, jfk, jfk],
                [p1, c2, jfk, kfc],
                [p1, c2, kfc, sfo],
                [p1, c2, kfc, jfk],
                [p1, c2, kfc, kfc],
                [p1, c3, sfo, sfo],
                [p1, c3, sfo, jfk],
                [p1, c3, sfo, kfc],
                [p1, c3, jfk, sfo],
                [p1, c3, jfk, jfk],
                [p1, c3, jfk, kfc],
                [p1, c3, kfc, sfo],
                [p1, c3, kfc, jfk],
                [p1, c3, kfc, kfc],
                [p1, c4, sfo, sfo],
                [p1, c4, sfo, jfk],
                [p1, c4, sfo, kfc],
                [p1, c4, jfk, sfo],
                [p1, c4, jfk, jfk],
                [p1, c4, jfk, kfc],
                [p1, c4, kfc, sfo],
                [p1, c4, kfc, jfk],
                [p1, c4, kfc, kfc],
                [p2, c1, sfo, sfo],
                [p2, c1, sfo, jfk],
                [p2, c1, sfo, kfc],
                [p2, c1, jfk, sfo],
                [p2, c1, jfk, jfk],
                [p2, c1, jfk, kfc],
                [p2, c1, kfc, sfo],
                [p2, c1, kfc, jfk],
                [p2, c1, kfc, kfc],
                [p2, c2, sfo, sfo],
                [p2, c2, sfo, jfk],
                [p2, c2, sfo, kfc],
                [p2, c2, jfk, sfo],
                [p2, c2, jfk, jfk],
                [p2, c2, jfk, kfc],
                [p2, c2, kfc, sfo],
                [p2, c2, kfc, jfk],
                [p2, c2, kfc, kfc],
                [p2, c3, sfo, sfo],
                [p2, c3, sfo, jfk],
                [p2, c3, sfo, kfc],
                [p2, c3, jfk, sfo],
                [p2, c3, jfk, jfk],
                [p2, c3, jfk, kfc],
                [p2, c3, kfc, sfo],
                [p2, c3, kfc, jfk],
                [p2, c3, kfc, kfc],
                [p2, c4, sfo, sfo],
                [p2, c4, sfo, jfk],
                [p2, c4, sfo, kfc],
                [p2, c4, jfk, sfo],
                [p2, c4, jfk, jfk],
                [p2, c4, jfk, kfc],
                [p2, c4, kfc, sfo],
                [p2, c4, kfc, jfk],
                [p2, c4, kfc, kfc]]
    assert_equal expected, variables
  end

  def test_permutate_arguments_less_than_params
    PDDL.parse(<<-PDDL)
(define (domain cargo)
  (:types cargo plane airport)
  (:predicates (at ?p - plane ?a - airport)
               (in ?c - cargo ?p - plane))
  (:action fly
      :parameters (?p - plane ?c - cargo ?from - airport ?to - airport)
      :precondition (at ?p ?from)
      :effect (and (not (at ?p ?from)) (at ?p ?to))))
PDDL
    problem = PDDL.parse(<<-PDDL)
(define (problem cargo-a) (:domain cargo)
  (:objects p1 p2 - plane sfo jfk - airport)
  (:init (at p1 jfk))
  (:goal (at p1 sfo)))
PDDL
    fly = problem[:actions][0]

    params = Parameters.new(fly)
    p1, p2, sfo, jfk = problem[:objects]
    assert_equal [], params.permutate([])
    assert_equal [], params.permutate([p1])
    assert_equal [], params.permutate([p1, sfo])
    assert_equal [], params.permutate([p1, p2, sfo, jfk])
  end

  def test_propositionalize_simple_case
    PDDL.parse(<<-PDDL)
(define (domain cargo)
  (:types cargo plane airport)
  (:predicates (at ?p - plane ?a - airport)
               (in ?c - cargo ?p - plane))
  (:action fly
      :parameters (?p - plane ?from - airport ?to - airport)
      :precondition (at ?p ?from)
      :effect (at ?p ?to)))
PDDL
    problem = PDDL.parse(<<-PDDL)
(define (problem cargo-a) (:domain cargo)
  (:objects p1 p2 - plane sfo jfk - airport)
  (:init (at p1 jfk))
  (:goal (at p1 sfo)))
PDDL
    fly = problem[:actions][0]

    params = Parameters.new(fly)
    p1, p2, sfo, jfk = problem[:objects]
    pred = problem[:predicates][0]
    assert_equal :at, pred.name

    actions = params.propositionalize([p1, sfo, jfk])
    assert_equal 4, actions.size

    assert_equal fact(pred, [p1, sfo]), actions[0].precond
    assert_equal fact(pred, [p1, sfo]), actions[0].effect

    assert_equal fact(pred, [p1, sfo]), actions[1].precond
    assert_equal fact(pred, [p1, jfk]), actions[1].effect

    assert_equal fact(pred, [p1, jfk]), actions[2].precond
    assert_equal fact(pred, [p1, sfo]), actions[2].effect

    assert_equal fact(pred, [p1, jfk]), actions[3].precond
    assert_equal fact(pred, [p1, jfk]), actions[3].effect
  end

  def test_propositionalize_should_eval_formulas_in_precondition
    PDDL.parse(<<-PDDL)
(define (domain cargo)
  (:types cargo plane airport)
  (:predicates (at ?p - plane ?a - airport)
               (in ?c - cargo ?p - plane))
  (:action fly
      :parameters (?p - plane ?from - airport ?to - airport)
      :precondition (and (at ?p ?from) (not (= ?from ?to)))
      :effect (and (not (at ?p ?from)) (at ?p ?to))))
PDDL
    problem = PDDL.parse(<<-PDDL)
(define (problem cargo-a) (:domain cargo)
  (:objects p1 p2 - plane sfo jfk - airport)
  (:init (at p1 jfk))
  (:goal (at p1 sfo)))
PDDL
    fly = problem[:actions][0]

    params = Parameters.new(fly)
    p1, p2, sfo, jfk = problem[:objects]
    pred = problem[:predicates][0]
    assert_equal :at, pred.name

    actions = params.propositionalize([p1, sfo, jfk])
    assert_equal 2, actions.size

    assert_equal fact(pred, [p1, sfo]), actions[0].precond
    assert_equal "(and (not (at p1 sfo)) (at p1 jfk))", actions[0].effect.to_s

    assert_equal fact(pred, [p1, jfk]), actions[1].precond
    assert_equal "(and (not (at p1 jfk)) (at p1 sfo))", actions[1].effect.to_s
  end

  def test_propositionalize_should_ignore_action_having_conflict_precond
    PDDL.parse(<<-PDDL)
(define (domain cargo)
  (:types cargo plane airport)
  (:predicates (at ?p - plane ?a - airport)
               (in ?c - cargo ?p - plane))
  (:action fly
      :parameters (?p - plane ?from - airport ?to - airport)
      :precondition (at ?p ?from)
      :effect (and (not (at ?p ?from)) (at ?p ?to))))
PDDL
    problem = PDDL.parse(<<-PDDL)
(define (problem cargo-a) (:domain cargo)
  (:objects p1 p2 - plane sfo jfk - airport)
  (:init (at p1 jfk))
  (:goal (at p1 sfo)))
PDDL
    fly = problem[:actions][0]

    params = Parameters.new(fly)
    p1, p2, sfo, jfk = problem[:objects]
    pred = problem[:predicates][0]
    assert_equal :at, pred.name

    actions = params.propositionalize([p1, sfo, jfk])
    assert_equal 2, actions.size

    assert_equal fact(pred, [p1, sfo]), actions[0].precond
    assert_equal "(and (not (at p1 sfo)) (at p1 jfk))", actions[0].effect.to_s

    assert_equal fact(pred, [p1, jfk]), actions[1].precond
    assert_equal "(and (not (at p1 jfk)) (at p1 sfo))", actions[1].effect.to_s
  end

#   def test_propositionalize_should_ignore_action_having_conflict_effect
#     action = {
#       name: :fly,
#       parameters: [[:p, :plane], [:from, :airport], [:to, :airport]],
#       precond: [[:at, :p, :from]],
#       effect: [
#         [:at, :p, :to],
#         [:-, :at, :p, :from]
#       ]
#     }
#     params = parameters(action[:parameters], [:plane, :airport, :cargo])
#     actions = params.propositionalize(action, [
#                                         [:p1, :plane],
#                                         [:sfo, :airport],
#                                         [:jfk, :airport]
#                                       ])
#     ret = actions.map{|a|a[:describe].call}
#     assert_equal ["fly(p1 sfo jfk)", "fly(p1 jfk sfo)"].sort, ret.sort
#   end

#   def test_type_inhierencing
#     action = {
#       name: :load,
#       parameters: [[:c, :cargo], [:p, :plane], [:a, :airport]],
#       precond: [
#         [:at, :c, :a],
#         [:at, :p, :a]
#       ],
#       effect: [
#         [:-, :at, :c, :a],
#         [:in, :c, :p]
#       ]
#     }
#     types = [
#       [:cargo, :object],
#       [:plane, :object],
#       [:airport, :object],
#       [:car, :cargo]
#     ]
#     params = parameters(action[:parameters], types)
#     actions = params.propositionalize(action, [
#                                         [:p1, :plane],
#                                         [:sfo, :airport],
#                                         [:modelx, :car],
#                                         [:box, :cargo]
#                                       ])
#     assert_equal 2, actions.size
#     assert_equal [literal([:at, :modelx, :sfo]),
#                   literal([:at, :p1, :sfo])],
#                  actions[0][:precond]
#     assert_equal [literal([:at, :box, :sfo]),
#                   literal([:at, :p1, :sfo])],
#                  actions[1][:precond]
#   end

#   def test_handles_no_types_case
#     action = {
#       name: :fly,
#       precond: [[:at, :sfo]],
#       effect: [
#         [:at, :jfk],
#         [:-, :at, :sfo]
#       ]
#     }
#     params = parameters(nil, nil)
#     actions = params.propositionalize(action, [:sfo, :jfk])
#     assert_equal 1, actions.size
#     assert_equal [literal([:at, :sfo])], actions[0][:precond]
#     assert_equal [literal([:at, :jfk]), literal([:-, :at, :sfo])],
#                  actions[0][:effect]
#   end

#   def test_handles_no_inherent_types
#     action = {
#       name: :fly,
#       precond: [[:at, :from], [:!=, :from, :to]],
#       effect: [
#         [:at, :to],
#         [:-, :at, :from]
#       ]
#     }
#     params = parameters([[:from, :airport], [:to, :airport]],
#                         [:plane, :airport])
#     objs = [[:sfo, :airport], [:jfk, :airport]]
#     actions = params.propositionalize(action, objs)
#     expected = [{
#                   name: :fly,
#                   describe: "fly(sfo jfk)",
#                   precond: [literal([:at, :sfo])],
#                   effect: [
#                     literal([:at, :jfk]),
#                     literal([:-, :at, :sfo])
#                   ]
#                 },
#                 {
#                   name: :fly,
#                   describe: "fly(jfk sfo)",
#                   precond: [literal([:at, :jfk])],
#                   effect: [
#                     literal([:at, :sfo]),
#                     literal([:-, :at, :jfk])
#                   ]
#                 }
#                ]

#     assert_equal 2, actions.size
#     assert_equal expected[0][:name], actions[0][:name]
#     assert_equal expected[0][:describe], actions[0][:describe].call
#     assert_equal expected[0][:effect], actions[0][:effect]
#     assert_equal expected[0][:precond], actions[0][:precond]

#     assert_equal expected[1][:name], actions[1][:name]
#     assert_equal expected[1][:describe], actions[1][:describe].call
#     assert_equal expected[1][:effect], actions[1][:effect]
#     assert_equal expected[1][:precond], actions[1][:precond]
#   end

#   def four_arguments
#     [[:p1, :plane], [:p2, :plane], [:sfo, :airport], [:jfk, :airport]]
#   end

#   def six_arguments
#     [[:p1, :plane], [:p2, :plane],
#      [:sfo, :airport], [:jfk, :airport], [:kfc, :airport],
#      [:c1, :cargo], [:c2, :cargo], [:c3, :cargo], [:c4, :cargo]]
#   end
end
