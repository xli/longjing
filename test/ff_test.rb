require "test_helper"

class FFTest < Test::Unit::TestCase
  include Longjing

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
    fact_layers = graph.layers(prob.goal.pos, prob.initial)
    assert_equal 0, fact_layers[Literal.create([:have, :cake])]
    assert_equal 1, fact_layers[Literal.create([:eaten, :cake])]
    assert_equal 2, fact_layers.size

    action_layers = Hash[graph.actions.map{|a| [a.describe, a.layer]}]
    assert_equal 0, action_layers["eat()"]
    assert_equal 0, action_layers["bake()"]

    fact_layers, layered_actions = graph.layers(prob.goal.pos, State.new(Literal.set([[:eaten, :cake]])))
    assert_equal 1, fact_layers[Literal.create([:have, :cake])]
    assert_equal 0, fact_layers[Literal.create([:eaten, :cake])]
    assert_equal 2, fact_layers.size

    action_layers = Hash[graph.actions.map{|a| [a.describe, a.layer]}]
    assert_equal Float::INFINITY, action_layers["eat()"]
    assert_equal 0, action_layers["bake()"]
  end

  def test_relaxed_layer_memberships_cargo_problem
    prob = problem(cargo_transportation_problem)
    graph = relaxed_graph_plan(prob)
    fact_layers, layered_actions = graph.layers(prob.goal.pos, prob.initial)
    assert_equal 0, fact_layers[Literal.create([:at, :c1, :sfo])]
    assert_equal 0, fact_layers[Literal.create([:at, :c2, :jfk])]
    assert_equal 0, fact_layers[Literal.create([:at, :p1, :sfo])]
    assert_equal 0, fact_layers[Literal.create([:at, :p2, :jfk])]
    assert_equal 1, fact_layers[Literal.create([:in, :c1, :p1])]
    assert_equal 1, fact_layers[Literal.create([:at, :p1, :jfk])]
    assert_equal 1, fact_layers[Literal.create([:in, :c2, :p2])]
    assert_equal 1, fact_layers[Literal.create([:at, :p2, :sfo])]
    assert_equal 2, fact_layers[Literal.create([:in, :c2, :p1])]
    assert_equal 2, fact_layers[Literal.create([:at, :c1, :jfk])]
    assert_equal 2, fact_layers[Literal.create([:in, :c1, :p2])]
    assert_equal 2, fact_layers[Literal.create([:at, :c2, :sfo])]

    action_layers = Hash[graph.actions.map{|a| [a.describe, a.layer]}]
    assert_equal 0, action_layers["load(c1 p1 sfo)"]
    assert_equal 0, action_layers["fly(p1 sfo jfk)"]
    assert_equal 0, action_layers["load(c2 p2 jfk)"]
    assert_equal 0, action_layers["fly(p2 jfk sfo)"]
    assert_equal 1, action_layers["unload(c1 p1 sfo)"]
    assert_equal 1, action_layers["load(c2 p1 jfk)"]
    assert_equal 1, action_layers["unload(c1 p1 jfk)"]
    assert_equal 1, action_layers["fly(p1 jfk sfo)"]
    assert_equal 1, action_layers["unload(c2 p2 jfk)"]
    assert_equal 1, action_layers["load(c1 p2 sfo)"]
    assert_equal 1, action_layers["unload(c2 p2 sfo)"]
    assert_equal 1, action_layers["fly(p2 sfo jfk)"]
  end

  def test_extract_solution_cake_problem
    prob = problem(cake_problem)
    graph = relaxed_graph_plan(prob)
    expected = [['eat()']]
    plan = graph.extract(prob.goal.pos, prob.initial)[0]
    assert_equal expected, plan.map{|a|a.map(&:describe)}
    state = State.new(Literal.set([[:eaten, :cake]]))
    plan = graph.extract(prob.goal.pos, state)[0]
    assert_equal [['bake()']], plan.map{|a|a.map(&:describe)}
  end

  def test_extract_solution_cargo_problem
    prob = problem(cargo_transportation_problem)
    graph = relaxed_graph_plan(prob)
    expected = [
      ["unload(c1 p1 jfk)", "unload(c2 p2 sfo)"],
      ["load(c1 p1 sfo)", "fly(p1 sfo jfk)", "load(c2 p2 jfk)", "fly(p2 jfk sfo)"]
    ]
    assert_equal expected, graph.extract(prob.goal.pos, prob.initial)[0].map{|a|a.map(&:describe)}
  end

  def test_extract_when_there_is_no_solution
    bwp = blocks_world_problem
    prob = problem(bwp)
    graph = relaxed_graph_plan(prob)
    state = State.new(Literal.set([[:on, :D, :E],
                                   [:block, :D],
                                   [:block, :E]]))
    assert_nil graph.extract(prob.goal.pos, state)
  end

  def test_relaxed_plan_by_blocksworld_4op_problem
    load(pddl_file('blocksworld-4ops'))
    prob = problem(load(pddl_file('bw-rand-4')))
    graph = relaxed_graph_plan(prob)

    {
      "((on b1 b2) (on b2 b4) (on-table b4) (clear b1) (holding b3))" => [
        ["putdown(b3)"],
        ["unstack(b1 b2)"],
        ["unstack(b2 b4)"],
        ["stack(b3 b4)", "pickup(b4)"],
        ["stack(b4 b1)"]
      ],
      "((on b2 b4) (on-table b3) (on-table b4) (clear b3) (holding b1) (clear b2))" => [
        ["stack(b1 b2)"],
        ["unstack(b2 b4)", "pickup(b3)"],
        ["stack(b3 b4)", "pickup(b4)"],
        ["stack(b4 b1)"]
      ],
      "((on b2 b4) (on-table b3) (on-table b4) (clear b3) (clear b2) (clear b1) (arm-empty) (on-table b1))" => [
        ["pickup(b1)", "unstack(b2 b4)", "pickup(b3)"],
        ['stack(b1 b2)', 'stack(b3 b4)', 'pickup(b4)'],
        ['stack(b4 b1)']
      ],
      "((on-table b3) (on-table b4) (clear b3) (clear b4) (on-table b2) (arm-empty) (clear b1) (on b1 b2))" => [
        ['pickup(b3)', 'pickup(b4)'],
        ['stack(b3 b4)', 'stack(b4 b1)']
      ],
      '((on-table b4) (clear b4) (on-table b2) (clear b1) (on b1 b2) (holding b3))' => [
        ['stack(b3 b4)'],
        ['pickup(b4)'],
        ['stack(b4 b1)']
      ],
      '((on-table b4) (clear b4) (on-table b2) (on b1 b2) (arm-empty) (clear b3) (on b3 b1))' => [
        ['unstack(b3 b1)', 'pickup(b4)'],
        ['stack(b3 b4)', 'stack(b4 b1)']
      ],
      '((on-table b4) (clear b4) (on-table b2) (clear b3) (on-table b3) (holding b1) (clear b2))' => [
        ['stack(b1 b2)'],
        ['pickup(b3)', 'pickup(b4)'],
        ['stack(b3 b4)', 'stack(b4 b1)']
      ],
      '((on-table b2) (on b1 b2) (clear b3) (on-table b3) (arm-empty) (clear b4) (on b4 b1))' => [
        ['pickup(b3)'],
        ['stack(b3 b4)']
      ],
      '((on-table b2) (on b1 b2) (clear b4) (on b4 b1) (clear b3) (arm-empty) (on-table b3))' => [
        ['pickup(b3)'],
        ['stack(b3 b4)']
      ],
      '((on-table b2) (on b1 b2) (on b4 b1) (arm-empty) (clear b3) (on b3 b4))' => []
    }.each do |lits, expected_plan|
      s = state(Literal.set(PDDL.new.parse(lits)))
      plan = graph.extract(prob.goal.pos, s)[0].reverse.map {|s|s.map(&:describe)}
      expected_plan.each_with_index do |step, i|
        assert_equal step, plan[i]
      end
      assert_equal expected_plan.size, plan.size
    end
  end

  def test_extracting_helpful_actions
    prob_desc = {
      objects: [:a, :b, :c],
      init: [
        [:holding, :c],
        [:on_table, :a],
        [:on_table, :b],
        [:clear, :a],
        [:clear, :b]
      ],
      goal: [
        [:on, :a, :b]
      ],
      actions: blocks_world_4ops_problem[:actions]
    }
    prob = problem(prob_desc)
    graph = relaxed_graph_plan(prob)
    solution = graph.extract(prob.goal.pos, prob.initial)
    assert_equal ['putdown(c)', 'stack(c a)', 'stack(c b)'],
                 solution[1].map(&:describe)
  end

  def test_extracting_helpful_actions2
    prob_desc = {
      objects: [:a, :b, :c, :d, :e],
      init: [
        [:on_table, :a],
        [:on_table, :b],
        [:on_table, :c],
        [:on_table, :d],
        [:on_table, :e],
        [:clear, :a],
        [:clear, :b],
        [:clear, :c],
        [:clear, :d],
        [:clear, :e],
        [:arm_empty]
      ],
      goal: [
        [:on, :a, :b]
      ],
      actions: blocks_world_4ops_problem[:actions]
    }
    prob = problem(prob_desc)
    graph = relaxed_graph_plan(prob)
    solution = graph.extract(prob.goal.pos, prob.initial)
    assert_equal ['pickup(a)'], solution[1].map(&:describe)
  end

  def test_added_goal_deletion
    prob_desc = {
      objects: [:a, :b, :c],
      init: [
        [:on, :c, :a],
        [:on_table, :a],
        [:on_table, :b],
        [:clear, :c],
        [:clear, :b],
        [:arm_empty]
      ],
      goal: [
        [:on, :a, :b],
        [:on, :c, :a],
        [:clear, :c]
      ],
      actions: blocks_world_4ops_problem[:actions]
    }
    prob = problem(prob_desc)
    graph = relaxed_graph_plan(prob)
    solution = graph.extract(prob.goal.pos, prob.initial, [])
    assert_equal([["stack(a b)"], ["pickup(a)"], ["unstack(c a)"]],
                 solution[0].map{|r|r.map(&:describe)})
    solution = graph.extract(prob.goal.pos, prob.initial, [Literal.create([:on, :c, :a])])
    assert_nil solution
  end

  def test_added_goal_deletion2
    prob_desc = {
      objects: [:a, :b, :c],
      init: [
        [:on, :a, :b],
        [:on_table, :a],
        [:on_table, :c],
        [:clear, :c],
        [:clear, :a],
        [:arm_empty]
      ],
      goal: [
        [:on, :a, :b],
        [:on, :c, :a],
        [:clear, :c]
      ],
      actions: blocks_world_4ops_problem[:actions]
    }
    prob = problem(prob_desc)
    graph = relaxed_graph_plan(prob)
    solution = graph.extract(prob.goal.pos, prob.initial, [Literal.create([:on, :a, :b])])
    assert_equal([['stack(c a)'], ['pickup(c)']],
                 solution[0].map {|r|r.map(&:describe)})
  end

  def test_resolve_cake_problem
    prob = problem(cake_problem)
    search = FF::Search.new
    ret = search.resolve(prob)
    validate!(problem(cake_problem), ret[:solution])
  end

  def test_resolve_cargo_problem
    prob = problem(cargo_transportation_problem)
    search = FF::Search.new
    ret = search.resolve(prob)
    validate!(problem(cargo_transportation_problem), ret[:solution])
  end

  def test_resolve_blocks_world_4op_problem
    prob = problem(blocks_world_4ops_problem)
    search = FF::Search.new
    ret = search.resolve(prob)
    validate!(problem(blocks_world_4ops_problem), ret[:solution])
  end

  def test_resolve_test_problem
    prob = problem(test_problem)
    search = FF::Search.new
    ret = search.resolve(prob)
    validate!(problem(test_problem), ret[:solution])
  end

  def test_greedy_search_blocks_world_4op_problem
    prob = problem(blocks_world_4ops_problem)
    graph = relaxed_graph_plan(prob)

    search = FF::Search.new
    ret = search.greedy_search(prob, graph)
    validate!(problem(blocks_world_4ops_problem), ret[:solution])
  end

  def test_ordering
    prob_desc = {
      objects: [:b1, :b2, :b3, :b4],
      init: [[:arm_empty],
             [:on_table, :b1],
             [:on_table, :b2],
             [:on_table, :b3],
             [:on_table, :b4],
             [:clear, :b1],
             [:clear, :b2],
             [:clear, :b3],
             [:clear, :b4]],
      goal: [
        [:on, :b1, :b2],
        [:on, :b2, :b3]
      ],
      actions: blocks_world_4ops_problem[:actions]
    }

    prob = problem(prob_desc)
    o = ordering(prob)
    fda = o.da(Literal.create([:on, :b1, :b2])).keys
    assert_equal [Literal.create([:clear, :b2]),
                  Literal.create([:holding, :b1])], fda

    facts, actions = o.heuristic_fixpoint_reduction(Literal.create([:on, :b1, :b2]))
    assert_equal [Literal.create([:clear, :b2]),
                  Literal.create([:holding, :b1])], facts.keys

    assert o.heuristic_ordering(Literal.create([:on, :b1, :b2]),
                                Literal.create([:on, :b3, :b4]))

    assert o.heuristic_ordering(Literal.create([:on, :b2, :b3]),
                                Literal.create([:on, :b1, :b2]))
    assert !o.heuristic_ordering(Literal.create([:on, :b1, :b2]),
                                 Literal.create([:on, :b2, :b3]))

    agenda = o.goal_agenda(prob)
    assert_equal ['(on b2 b3)', '(on b1 b2)'], agenda.map(&:to_s)
  end

  def test_build_goal_agenda1
    prob = problem(blocks_world_4ops_problem)
    agenda = ordering(prob).goal_agenda(prob)
    assert_equal ['(on b4 b6)', '(on b1 b4)', '(on b3 b1)',
                  '(on b5 b3)'], agenda.map(&:to_s)
  end

  def test_build_goal_agenda2
    PDDL.parse(read_pddl('blocksworld-4ops'))
    pddl = PDDL.parse(read_pddl("blocksworld-4ops-rand-8"))
    prob = problem(pddl)

    agenda = ordering(prob).goal_agenda(prob)
    expected = ["(on b6 b8)", "(on b7 b6)",
                "(on b2 b7)", "(on b3 b2)",
                "(on b4 b3)", "(on b1 b5)"]
    assert_equal expected, agenda.map(&:to_s)
  end

  def ordering(prob)
    FF::Ordering.new(FF::ConnectivityGraph.new(prob))
  end

  def relaxed_graph_plan(prob)
    FF::RelaxedGraphPlan.new(FF::ConnectivityGraph.new(prob))
  end
end
