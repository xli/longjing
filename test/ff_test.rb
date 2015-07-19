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

    assert_equal 0, action_layers[graph.action_id([:eat])]
    assert_equal 0, action_layers[graph.action_id([:bake])]
    assert_equal 2, action_layers.size

    fact_layers, action_layers = graph.layers(State.new(Literal.set([[:eaten, :cake]])))
    assert_equal 1, fact_layers[Literal.create([:have, :cake])]
    assert_equal 0, fact_layers[Literal.create([:eaten, :cake])]
    assert_equal 2, fact_layers.size

    assert_equal nil, action_layers[graph.action_id([:eat])]
    assert_equal 0, action_layers[graph.action_id([:bake])]
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

    assert_equal 0, action_layers[graph.action_id([:load, :c1, :p1, :sfo])]
    assert_equal 0, action_layers[graph.action_id([:fly, :p1, :sfo, :sfo])]
    assert_equal 0, action_layers[graph.action_id([:fly, :p1, :sfo, :jfk])]
    assert_equal 0, action_layers[graph.action_id([:load, :c2, :p2, :jfk])]
    assert_equal 0, action_layers[graph.action_id([:fly, :p2, :jfk, :sfo])]
    assert_equal 0, action_layers[graph.action_id([:fly, :p2, :jfk, :jfk])]
    assert_equal 1, action_layers[graph.action_id([:unload, :c1, :p1, :sfo])]
    assert_equal 1, action_layers[graph.action_id([:load, :c2, :p1, :jfk])]
    assert_equal 1, action_layers[graph.action_id([:unload, :c1, :p1, :jfk])]
    assert_equal 1, action_layers[graph.action_id([:fly, :p1, :jfk, :sfo])]
    assert_equal 1, action_layers[graph.action_id([:fly, :p1, :jfk, :jfk])]
    assert_equal 1, action_layers[graph.action_id([:unload, :c2, :p2, :jfk])]
    assert_equal 1, action_layers[graph.action_id([:load, :c1, :p2, :sfo])]
    assert_equal 1, action_layers[graph.action_id([:unload, :c2, :p2, :sfo])]
    assert_equal 1, action_layers[graph.action_id([:fly, :p2, :sfo, :sfo])]
    assert_equal 1, action_layers[graph.action_id([:fly, :p2, :sfo, :jfk])]
  end

  def test_extract_solution_cake_problem
    prob = problem(cake_problem)
    graph = FF::RelaxedGraphPlan.new(prob)
    expected = [[[:eat]]]
    assert_equal expected, graph.extract(prob.initial).map{|a|a.map(&:name)}
    state = State.new(Literal.set([[:eaten, :cake]]))
    assert_equal [[[:bake]]], graph.extract(state).map{|a|a.map(&:name)}
  end

  def test_extract_solution_cargo_problem
    prob = problem(cargo_transportation_problem)
    graph = FF::RelaxedGraphPlan.new(prob)
    expected = [
      [
        [:unload, :c1, :p1, :jfk],
        [:unload, :c2, :p2, :sfo]
      ],
      [
        [:load, :c1, :p1, :sfo],
        [:fly, :p1, :sfo, :jfk],
        [:load, :c2, :p2, :jfk],
        [:fly, :p2, :jfk, :sfo]
      ]
    ]
    assert_equal expected, graph.extract(prob.initial).map{|a|a.map(&:name)}
  end

  def test_distance
    prob = problem(cargo_transportation_problem)
    graph = FF::RelaxedGraphPlan.new(prob)
    assert_equal 6, graph.distance(prob.initial)
  end

  def test_distance_when_there_is_no_solution
    bwp = blocks_world_problem
    prob = problem(bwp)
    graph = FF::RelaxedGraphPlan.new(prob)
    state = State.new(Literal.set([[:on, :D, :E],
                                   [:block, :D],
                                   [:block, :E]]))
    assert_nil graph.distance(state)
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
