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
    graph = FF::RelaxedGraphPlan.new(prob)
    fact_layers, action_layers = graph.layers(prob.initial)
    assert_equal 0, fact_layers[Literal.create([:have, :cake])]
    assert_equal 1, fact_layers[Literal.create([:eaten, :cake])]
    assert_equal 2, fact_layers.size

    assert_equal 0, action_layers[graph.action_id("eat()")]
    assert_equal 0, action_layers[graph.action_id("bake()")]
    assert_equal 2, action_layers.size

    fact_layers, action_layers = graph.layers(State.new(Literal.set([[:eaten, :cake]])))
    assert_equal 1, fact_layers[Literal.create([:have, :cake])]
    assert_equal 0, fact_layers[Literal.create([:eaten, :cake])]
    assert_equal 2, fact_layers.size

    assert_equal nil, action_layers[graph.action_id("eat()")]
    assert_equal 0, action_layers[graph.action_id("bake()")]
    assert_equal 1, action_layers.size
  end

  def test_relaxed_layer_memberships_cargo_problem
    prob = problem(cargo_transportation_problem)
    graph = FF::RelaxedGraphPlan.new(prob)
    fact_layers, action_layers = graph.layers(prob.initial)
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

    assert_equal 0, action_layers[graph.action_id("load(c1 p1 sfo)")]
    assert_equal 0, action_layers[graph.action_id("fly(p1 sfo sfo)")]
    assert_equal 0, action_layers[graph.action_id("fly(p1 sfo jfk)")]
    assert_equal 0, action_layers[graph.action_id("load(c2 p2 jfk)")]
    assert_equal 0, action_layers[graph.action_id("fly(p2 jfk sfo)")]
    assert_equal 0, action_layers[graph.action_id("fly(p2 jfk jfk)")]
    assert_equal 1, action_layers[graph.action_id("unload(c1 p1 sfo)")]
    assert_equal 1, action_layers[graph.action_id("load(c2 p1 jfk)")]
    assert_equal 1, action_layers[graph.action_id("unload(c1 p1 jfk)")]
    assert_equal 1, action_layers[graph.action_id("fly(p1 jfk sfo)")]
    assert_equal 1, action_layers[graph.action_id("fly(p1 jfk jfk)")]
    assert_equal 1, action_layers[graph.action_id("unload(c2 p2 jfk)")]
    assert_equal 1, action_layers[graph.action_id("load(c1 p2 sfo)")]
    assert_equal 1, action_layers[graph.action_id("unload(c2 p2 sfo)")]
    assert_equal 1, action_layers[graph.action_id("fly(p2 sfo sfo)")]
    assert_equal 1, action_layers[graph.action_id("fly(p2 sfo jfk)")]
  end

  def test_extract_solution_cake_problem
    prob = problem(cake_problem)
    graph = FF::RelaxedGraphPlan.new(prob)
    expected = [['eat()']]
    assert_equal expected, graph.extract(prob.initial).map{|a|a.map(&:describe)}
    state = State.new(Literal.set([[:eaten, :cake]]))
    assert_equal [['bake()']], graph.extract(state).map{|a|a.map(&:describe)}
  end

  def test_extract_solution_cargo_problem
    prob = problem(cargo_transportation_problem)
    graph = FF::RelaxedGraphPlan.new(prob)
    expected = [
      ["unload(c1 p1 jfk)", "unload(c2 p2 sfo)"],
      ["load(c1 p1 sfo)", "fly(p1 sfo jfk)", "load(c2 p2 jfk)", "fly(p2 jfk sfo)"]
    ]
    assert_equal expected, graph.extract(prob.initial).map{|a|a.map(&:describe)}
  end

  def test_extract_when_there_is_no_solution
    bwp = blocks_world_problem
    prob = problem(bwp)
    graph = FF::RelaxedGraphPlan.new(prob)
    state = State.new(Literal.set([[:on, :D, :E],
                                   [:block, :D],
                                   [:block, :E]]))
    assert_nil graph.extract(state)
  end

  def test_relaxed_plan_by_blocksworld_4op_problem
    load(pddl_file('blocksworld-4ops'))
    prob = problem(load(pddl_file('bw-rand-4')))
    graph = FF::RelaxedGraphPlan.new(prob)

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
      plan = graph.extract(s).reverse.map {|s|s.map(&:describe)}
      expected_plan.each_with_index do |step, i|
        assert_equal step, plan[i]
      end
      assert_equal expected_plan.size, plan.size
    end
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
end
