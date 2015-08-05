require "test_helper"

class FFTest < Test::Unit::TestCase
  include Longjing

  def teardown
    PDDL.domains.clear
  end

  def test_relaxed_layer_memberships_cake_problem
    # S0: have(cake)
    # A0:
    #     => have(cake)
    #     eat(cake)
    #     bake(cake)
    # S1:
    #     have(cake)
    #     eaten(cake)
    # A1:
    #     => have(cake)
    #     => eaten(cake)
    #     eat(cake)
    #     bake(cake)
    # S2:
    #     have(cake)
    #     eaten(cake)
    prob = problem(cake_problem)
    graph = relaxed_graph_plan(prob)
    graph.layers(prob.goal.to_a, prob.initial)
    have, eaten = graph.literals
    assert_equal '(have-cake)', have.to_s
    assert_equal '(eaten-cake)', eaten.to_s

    ll = literal_layers(graph)
    assert_equal 0, ll['(have-cake)']
    assert_equal 1, ll['(eaten-cake)']

    al = action_layers(graph)
    assert_equal 0, al["eat()"]
    assert_equal 0, al["bake()"]

    graph.layers(prob.goal.to_a, State.new([eaten].to_set))
    ll = literal_layers(graph)

    assert_equal 1, ll['(have-cake)']
    assert_equal 0, ll['(eaten-cake)']

    al = action_layers(graph)
    assert_equal Float::INFINITY, al["eat()"]
    assert_equal 0, al["bake()"]
  end

  def test_relaxed_layer_memberships_cargo_problem
    cargo = cargo_transportation_problem
    prob = problem(cargo)
    graph = relaxed_graph_plan(prob)
    graph.layers(prob.goal.to_a, prob.initial)
    ll = literal_layers(graph)
    assert_equal 0, ll['(at c1 sfo)']
    assert_equal 0, ll['(at c2 jfk)']
    assert_equal 0, ll['(at p1 sfo)']
    assert_equal 0, ll['(at p2 jfk)']
    assert_equal 1, ll['(in c1 p1)']
    assert_equal 1, ll['(at p1 jfk)']
    assert_equal 1, ll['(in c2 p2)']
    assert_equal 1, ll['(at p2 sfo)']
    assert_equal 2, ll['(in c2 p1)']
    assert_equal 2, ll['(at c1 jfk)']
    assert_equal 2, ll['(in c1 p2)']
    assert_equal 2, ll['(at c2 sfo)']

    al = action_layers(graph)
    assert_equal 0, al["load(c1 p1 sfo)"]
    assert_equal 0, al["fly(p1 sfo jfk)"]
    assert_equal 0, al["load(c2 p2 jfk)"]
    assert_equal 0, al["fly(p2 jfk sfo)"]
    assert_equal 1, al["unload(c1 p1 sfo)"]
    assert_equal 1, al["load(c2 p1 jfk)"]
    assert_equal 1, al["unload(c1 p1 jfk)"]
    assert_equal 1, al["fly(p1 jfk sfo)"]
    assert_equal 1, al["unload(c2 p2 jfk)"]
    assert_equal 1, al["load(c1 p2 sfo)"]
    assert_equal 1, al["unload(c2 p2 sfo)"]
    assert_equal 1, al["fly(p2 sfo jfk)"]
  end

  def test_extract_solution_cake_problem
    prob = problem(cake_problem)
    graph = relaxed_graph_plan(prob)
    expected = [['eat()']]
    plan = graph.extract(prob.goal.to_a, prob.initial)[0]
    assert_equal expected, signature(plan)

    have, eaten = graph.literals
    state = State.new([eaten].to_set)
    plan = graph.extract(prob.goal.to_a, state)[0]
    assert_equal [['bake()']], signature(plan)
  end

  def test_extract_solution_cargo_problem
    prob = problem(cargo_transportation_problem)
    graph = relaxed_graph_plan(prob)
    expected = [
      ["unload(c1 p1 jfk)", "unload(c2 p2 sfo)"],
      ["load(c1 p1 sfo)", "fly(p1 sfo jfk)", "load(c2 p2 jfk)", "fly(p2 jfk sfo)"]
    ]
    plan = graph.extract(prob.goal.to_a, prob.initial)[0]
    assert_equal expected, signature(plan)
  end

  def test_extract_when_there_is_no_solution
    domain = pddl(pddl_file('blocksworld-4ops'))
    bwp = PDDL.parse(<<-PDDL)
(define (problem bw-4)
        (:domain blocksworld)
        (:objects b1 b2 b3)
        (:init (arm-empty)
               (on-table b1)
               (on-table b2)
               (on-table b3)
               (clear b1)
               (clear b2)
               (clear b3))
        (:goal (on b1 b1)))
PDDL
    prob = problem(bwp)
    graph = relaxed_graph_plan(prob)
    assert_nil graph.extract(prob.goal.to_a, prob.initial)
  end

  def test_relaxed_plan_by_blocksworld_4op_problem
    pddl(pddl_file('blocksworld-4ops'))
    {
      "(on b1 b2) (on b2 b4) (on-table b4) (clear b1) (holding b3)" => [
        ["putdown(b3)"],
        ["unstack(b1 b2)"],
        ["unstack(b2 b4)"],
        ["stack(b3 b4)", "pickup(b4)"],
        ["stack(b4 b1)"]
      ],
      "(on b2 b4) (on-table b3) (on-table b4) (clear b3) (holding b1) (clear b2)" => [
        ["stack(b1 b2)"],
        ["unstack(b2 b4)", "pickup(b3)"],
        ["stack(b3 b4)", "pickup(b4)"],
        ["stack(b4 b1)"]
      ],
      "(on b2 b4) (on-table b3) (on-table b4) (clear b3) (clear b2) (clear b1) (arm-empty) (on-table b1)" => [
        ["pickup(b1)", "unstack(b2 b4)", "pickup(b3)"],
        ['stack(b1 b2)', 'stack(b3 b4)', 'pickup(b4)'],
        ['stack(b4 b1)']
      ],
      "(on-table b3) (on-table b4) (clear b3) (clear b4) (on-table b2) (arm-empty) (clear b1) (on b1 b2)" => [
        ['pickup(b3)', 'pickup(b4)'],
        ['stack(b3 b4)', 'stack(b4 b1)']
      ],
      '(on-table b4) (clear b4) (on-table b2) (clear b1) (on b1 b2) (holding b3)' => [
        ['stack(b3 b4)'],
        ['pickup(b4)'],
        ['stack(b4 b1)']
      ],
      '(on-table b4) (clear b4) (on-table b2) (on b1 b2) (arm-empty) (clear b3) (on b3 b1)' => [
        ['unstack(b3 b1)', 'pickup(b4)'],
        ['stack(b3 b4)', 'stack(b4 b1)']
      ],
      '(on-table b4) (clear b4) (on-table b2) (clear b3) (on-table b3) (holding b1) (clear b2)' => [
        ['stack(b1 b2)'],
        ['pickup(b3)', 'pickup(b4)'],
        ['stack(b3 b4)', 'stack(b4 b1)']
      ],
      '(on-table b2) (on b1 b2) (clear b3) (on-table b3) (arm-empty) (clear b4) (on b4 b1)' => [
        ['pickup(b3)'],
        ['stack(b3 b4)']
      ],
      '(on-table b2) (on b1 b2) (clear b4) (on b4 b1) (clear b3) (arm-empty) (on-table b3)' => [
        ['pickup(b3)'],
        ['stack(b3 b4)']
      ],
      '(on-table b2) (on b1 b2) (on b4 b1) (arm-empty) (clear b3) (on b3 b4)' => []
    }.each do |lits, expected_plan|
      prob = problem(PDDL.parse(<<-PDDL))
(define (problem bw-rand-4)
        (:domain blocksworld)
        (:objects b1 b2 b3 b4)
        (:init #{lits})
        (:goal (and (on b1 b2)
               (on b3 b4)
               (on b4 b1))))
PDDL
      graph = relaxed_graph_plan(prob)
      plan = graph.extract(prob.goal.to_a, prob.initial)[0]
      plan = signature(plan.reverse)
      expected_plan.each_with_index do |step, i|
        assert_equal step, plan[i]
      end
      assert_equal expected_plan.size, plan.size
    end
  end

  def test_extracting_helpful_actions
    pddl(pddl_file('blocksworld-4ops'))
    prob = problem(PDDL.parse(<<-PDDL))
(define (problem bw-rand-4)
        (:domain blocksworld)
        (:objects a b c)
        (:init (holding c)
               (on-table a)
               (on-table b)
               (clear a)
               (clear b))
        (:goal (on a b)))
PDDL

    graph = relaxed_graph_plan(prob)
    solution = graph.extract(prob.goal.to_a, prob.initial)
    assert_equal ['putdown(c)', 'stack(c a)', 'stack(c b)'],
                 solution[1].map(&:signature)
  end

  def test_extracting_helpful_actions2
    pddl(pddl_file('blocksworld-4ops'))
    prob = problem(PDDL.parse(<<-PDDL))
(define (problem bw-rand-4)
        (:domain blocksworld)
        (:objects a b c d e)
        (:init (arm-empty)
               (on-table a)
               (on-table b)
               (on-table c)
               (on-table d)
               (on-table e)
               (clear a)
               (clear b)
               (clear c)
               (clear d)
               (clear e))
        (:goal (on a b)))
PDDL

    graph = relaxed_graph_plan(prob)
    solution = graph.extract(prob.goal.to_a, prob.initial)
    assert_equal ['pickup(a)'],
                 solution[1].map(&:signature)
  end

  def test_added_goal_deletion
    pddl(pddl_file('blocksworld-4ops'))
    prob = problem(PDDL.parse(<<-PDDL))
(define (problem bw-rand-4)
        (:domain blocksworld)
        (:objects a b c)
        (:init (on c a)
               (on-table a)
               (on-table b)
               (clear c)
               (clear b)
               (arm-empty))
        (:goal (and (on a b) (on c a) (clear c))))
PDDL

    graph = relaxed_graph_plan(prob)
    solution = graph.extract(prob.goal.to_a, prob.initial, [])
    assert_equal ['stack(a b)', 'pickup(a)', 'unstack(c a)'],
                 signature(solution[0]).flatten
    on_c_a = prob.initial.raw.find {|l| l.to_s == '(on c a)'}
    assert on_c_a

    solution = graph.extract(prob.goal.to_a, prob.initial, [on_c_a])
    assert_nil solution
  end

  def test_added_goal_deletion2
    pddl(pddl_file('blocksworld-4ops'))
    prob = problem(PDDL.parse(<<-PDDL))
(define (problem bw-rand-4)
        (:domain blocksworld)
        (:objects a b c)
        (:init (on a b)
               (on-table a)
               (on-table c)
               (clear c)
               (clear a)
               (arm-empty))
        (:goal (and (on a b) (on c a) (clear c))))
PDDL

    graph = relaxed_graph_plan(prob)
    on_a_b = prob.initial.raw.find {|l| l.to_s == '(on a b)'}
    assert on_a_b

    solution = graph.extract(prob.goal.to_a, prob.initial, [on_a_b])
    assert_equal([['stack(c a)'], ['pickup(c)']],
                 signature(solution[0]))
  end

  def test_resolve_cake_problem
    search = Search.ff.new
    ret = search.search(cake_problem)
    validate!(cake_problem, ret)
  end

  def test_resolve_cargo_problem
    search = Search.ff.new
    ret = search.search(cargo_transportation_problem)
    validate!(cargo_transportation_problem, ret)
  end

  def test_resolve_blocks_world_4op_problem
    search = Search.ff.new
    ret = search.search(blocksworld_rand_8_problem)
    validate!(blocksworld_rand_8_problem, ret)
  end

  def test_greedy_search_blocks_world_4op_problem
    search = Search.ff_greedy.new
    ret = search.search(blocksworld_rand_8_problem)
    validate!(blocksworld_rand_8_problem, ret)
  end

  def test_ordering
    domain = pddl(pddl_file('blocksworld-4ops'))
    pddl_problem = PDDL.parse(<<-PDDL)
(define (problem bw-rand-4)
        (:domain blocksworld)
        (:objects b1 b2 b3 b4)
        (:init (on-table b1)
               (on-table b2)
               (on-table b3)
               (on-table b4)
               (clear b1)
               (clear b2)
               (clear b3)
               (clear b4)
               (arm-empty))
        (:goal (and (on b1 b2) (on b2 b3))))
PDDL
    prob = problem(pddl_problem)

    clear, on_table, arm_empty, holding, on = domain[:predicates]
    b1, b2, b3, b4 = pddl_problem[:objects]
    on_b1_b2, on_b2_b3 = prob.goal.to_a

    o = ordering(prob)
    fda = o.da(on_b1_b2).keys
    assert_equal [fact(clear, [b2]), fact(holding, [b1])], fda

    facts, actions = o.heuristic_fixpoint_reduction(on_b1_b2)
    assert_equal [fact(clear, [b2]), fact(holding, [b1])], facts.keys

    assert o.heuristic_ordering(fact(on, [b1, b2]),
                                fact(on, [b3, b4]))

    assert o.heuristic_ordering(fact(on, [b2, b3]),
                                fact(on, [b1, b2]))
    assert !o.heuristic_ordering(fact(on, [b1, b2]),
                                fact(on, [b2, b3]))
    agenda = o.goal_agenda(prob)
    assert_equal ['(on b2 b3)', '(on b1 b2)'], agenda.map(&:to_s)
  end

  def test_build_goal_agenda2
    pddl = blocksworld_rand_8_problem
    prob = problem(pddl)

    agenda = ordering(prob).goal_agenda(prob)
    expected = ["(on b6 b8)", "(on b7 b6)",
                "(on b2 b7)", "(on b3 b2)",
                "(on b4 b3)", "(on b1 b5)"]
    assert_equal expected, agenda.map(&:to_s)
  end

  def literal_layers(graph)
    Hash[graph.literals.map {|lit| [lit.to_s, lit.ff_layer]}]
  end

  def action_layers(graph)
    Hash[graph.actions.map{|a| [a.signature, a.layer]}]
  end

  def signature(plan)
    plan.map{|a|a.map(&:signature)}
  end

  def ordering(prob)
    FF::Ordering.new(cg(prob))
  end

  def relaxed_graph_plan(prob)
    FF::RelaxedGraphPlan.new(cg(prob))
  end

  def cg(prob)
    FF::ConnectivityGraph.new(prob)
  end

  def problem(prob)
    FF::Preprocess.new.execute(prob)
  end
end
