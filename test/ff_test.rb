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
    layers = graph.layers(prob.initial)
    assert_equal 0, layers[Literal.new([:have, :cake])]
    assert_equal 1, layers[Literal.new([:eaten, :cake])]
    assert_equal 0, layers[Literal.new([:action, [:eat]])]
    assert_equal 0, layers[Literal.new([:action, [:bake]])]
    assert_equal 4, layers.size

    layers = graph.layers(State.new(Literal.set([[:eaten, :cake]])))
    assert_equal 1, layers[Literal.new([:have, :cake])]
    assert_equal 0, layers[Literal.new([:eaten, :cake])]
    assert_equal 1, layers[Literal.new([:action, [:eat]])]
    assert_equal 0, layers[Literal.new([:action, [:bake]])]
    assert_equal 4, layers.size
  end

  def test_relaxed_layer_memberships_cargo_problem
    prob = problem(cargo_transportation_problem)
    graph = FF::RelaxedGraphPlan.new(prob)
    layers = graph.layers(prob.initial)
    assert_equal 0, layers[Literal.new([:at, :c1, :sfo])]
    assert_equal 0, layers[Literal.new([:at, :c2, :jfk])]
    assert_equal 0, layers[Literal.new([:at, :p1, :sfo])]
    assert_equal 0, layers[Literal.new([:at, :p2, :jfk])]
    assert_equal 0, layers[Literal.new([:action, [:load, :c1, :p1, :sfo]])]
    assert_equal 0, layers[Literal.new([:action, [:fly, :p1, :sfo, :sfo]])]
    assert_equal 0, layers[Literal.new([:action, [:fly, :p1, :sfo, :jfk]])]
    assert_equal 0, layers[Literal.new([:action, [:load, :c2, :p2, :jfk]])]
    assert_equal 0, layers[Literal.new([:action, [:fly, :p2, :jfk, :sfo]])]
    assert_equal 0, layers[Literal.new([:action, [:fly, :p2, :jfk, :jfk]])]
    assert_equal 1, layers[Literal.new([:in, :c1, :p1])]
    assert_equal 1, layers[Literal.new([:at, :p1, :jfk])]
    assert_equal 1, layers[Literal.new([:in, :c2, :p2])]
    assert_equal 1, layers[Literal.new([:at, :p2, :sfo])]
    assert_equal 1, layers[Literal.new([:action, [:unload, :c1, :p1, :sfo]])]
    assert_equal 1, layers[Literal.new([:action, [:load, :c2, :p1, :jfk]])]
    assert_equal 1, layers[Literal.new([:action, [:unload, :c1, :p1, :jfk]])]
    assert_equal 1, layers[Literal.new([:action, [:fly, :p1, :jfk, :sfo]])]
    assert_equal 1, layers[Literal.new([:action, [:fly, :p1, :jfk, :jfk]])]
    assert_equal 1, layers[Literal.new([:action, [:unload, :c2, :p2, :jfk]])]
    assert_equal 1, layers[Literal.new([:action, [:load, :c1, :p2, :sfo]])]
    assert_equal 1, layers[Literal.new([:action, [:unload, :c2, :p2, :sfo]])]
    assert_equal 1, layers[Literal.new([:action, [:fly, :p2, :sfo, :sfo]])]
    assert_equal 1, layers[Literal.new([:action, [:fly, :p2, :sfo, :jfk]])]
    assert_equal 2, layers[Literal.new([:in, :c2, :p1])]
    assert_equal 2, layers[Literal.new([:at, :c1, :jfk])]
    assert_equal 2, layers[Literal.new([:in, :c1, :p2])]
    assert_equal 2, layers[Literal.new([:at, :c2, :sfo])]
  end

  def test_extract_solution_cake_problem
    prob = problem(cake_problem)
    graph = FF::RelaxedGraphPlan.new(prob)
    expected = [[Literal.new([:action, [:eat]])]]
    assert_equal expected, graph.extract(prob.initial)
    state = State.new(Literal.set([[:eaten, :cake]]))
    assert_equal [[Literal.new([:action, [:bake]])]], graph.extract(state)
  end

  def test_extract_solution_cargo_problem
    prob = problem(cargo_transportation_problem)
    graph = FF::RelaxedGraphPlan.new(prob)
    expected = [
      [
        Literal.new([:action, [:unload, :c1, :p1, :jfk]]),
        Literal.new([:action, [:unload, :c2, :p2, :sfo]])
      ],
      [
        Literal.new([:action, [:load, :c1, :p1, :sfo]]),
        Literal.new([:action, [:fly, :p1, :sfo, :jfk]]),
        Literal.new([:action, [:load, :c2, :p2, :jfk]]),
        Literal.new([:action, [:fly, :p2, :jfk, :sfo]])
      ]
    ]
    assert_equal expected, graph.extract(prob.initial)
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
