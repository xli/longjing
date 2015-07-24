require "test_helper"

class ParametersTest < Test::Unit::TestCase
  include Longjing

  def test_no_typing
    params = parameters([:p, :to], nil)
    variables = params.permutate([:p1, :p2, :sfo, :jfk])
    assert_equal 4*4, variables.size
    expected = [
      {p: :p1,  to: :p1},
      {p: :p1,  to: :p2},
      {p: :p1,  to: :sfo},
      {p: :p1,  to: :jfk},
      {p: :p2,  to: :p1},
      {p: :p2,  to: :p2},
      {p: :p2,  to: :sfo},
      {p: :p2,  to: :jfk},
      {p: :sfo, to: :p1},
      {p: :sfo, to: :p2},
      {p: :sfo, to: :sfo},
      {p: :sfo, to: :jfk},
      {p: :jfk, to: :p1},
      {p: :jfk, to: :p2},
      {p: :jfk, to: :sfo},
      {p: :jfk, to: :jfk}
    ]
    assert_equal expected, variables
  end

  def test_permutate_empty_params
    params = parameters(nil)
    variables = params.permutate(four_arguments)
    assert_equal [{}], variables
    params = parameters([])
    variables = params.permutate(four_arguments)
    assert_equal [{}], variables
  end

  def test_permutate_one_params
    params = parameters([[:p, :plane]], [:plane, :airport, :cargo])
    variables = params.permutate(four_arguments)
    expected = [
      {p: :p1},
      {p: :p2}
    ]
    assert_equal expected, variables
  end

  def test_permutate_two_params
    params = parameters([[:p, :plane], [:to, :airport]], [:plane, :airport, :cargo])
    variables = params.permutate(four_arguments)
    assert_equal 4, variables.size
    expected = [{p: :p1, to: :sfo},
                {p: :p1, to: :jfk},
                {p: :p2, to: :sfo},
                {p: :p2, to: :jfk}]
    assert_equal expected, variables
  end

  def test_permutate_dup_types_params
    params = parameters([[:p, :plane],
                         [:from, :airport],
                         [:to, :airport]],
                        [:plane, :airport, :cargo])
    variables = params.permutate(four_arguments)
    assert_equal 2*2*2, variables.size
    expected = [
      {p: :p1, from: :sfo, to: :sfo},
      {p: :p1, from: :sfo, to: :jfk},
      {p: :p1, from: :jfk, to: :sfo},
      {p: :p1, from: :jfk, to: :jfk},
      {p: :p2, from: :sfo, to: :sfo},
      {p: :p2, from: :sfo, to: :jfk},
      {p: :p2, from: :jfk, to: :sfo},
      {p: :p2, from: :jfk, to: :jfk}
    ]

    assert_equal expected, variables
  end

  def test_permutate_four_params
    params = parameters([[:p, :plane], [:c, :cargo],
                         [:from, :airport], [:to, :airport]],
                       [:plane, :airport, :cargo])
    variables = params.permutate(six_arguments)
    assert_equal 2*4*3*3, variables.size
    expected = [{p: :p1, c: :c1, from: :sfo, to: :sfo},
                {p: :p1, c: :c1, from: :sfo, to: :jfk},
                {p: :p1, c: :c1, from: :sfo, to: :kfc},
                {p: :p1, c: :c1, from: :jfk, to: :sfo},
                {p: :p1, c: :c1, from: :jfk, to: :jfk},
                {p: :p1, c: :c1, from: :jfk, to: :kfc},
                {p: :p1, c: :c1, from: :kfc, to: :sfo},
                {p: :p1, c: :c1, from: :kfc, to: :jfk},
                {p: :p1, c: :c1, from: :kfc, to: :kfc},
                {p: :p1, c: :c2, from: :sfo, to: :sfo},
                {p: :p1, c: :c2, from: :sfo, to: :jfk},
                {p: :p1, c: :c2, from: :sfo, to: :kfc},
                {p: :p1, c: :c2, from: :jfk, to: :sfo},
                {p: :p1, c: :c2, from: :jfk, to: :jfk},
                {p: :p1, c: :c2, from: :jfk, to: :kfc},
                {p: :p1, c: :c2, from: :kfc, to: :sfo},
                {p: :p1, c: :c2, from: :kfc, to: :jfk},
                {p: :p1, c: :c2, from: :kfc, to: :kfc},
                {p: :p1, c: :c3, from: :sfo, to: :sfo},
                {p: :p1, c: :c3, from: :sfo, to: :jfk},
                {p: :p1, c: :c3, from: :sfo, to: :kfc},
                {p: :p1, c: :c3, from: :jfk, to: :sfo},
                {p: :p1, c: :c3, from: :jfk, to: :jfk},
                {p: :p1, c: :c3, from: :jfk, to: :kfc},
                {p: :p1, c: :c3, from: :kfc, to: :sfo},
                {p: :p1, c: :c3, from: :kfc, to: :jfk},
                {p: :p1, c: :c3, from: :kfc, to: :kfc},
                {p: :p1, c: :c4, from: :sfo, to: :sfo},
                {p: :p1, c: :c4, from: :sfo, to: :jfk},
                {p: :p1, c: :c4, from: :sfo, to: :kfc},
                {p: :p1, c: :c4, from: :jfk, to: :sfo},
                {p: :p1, c: :c4, from: :jfk, to: :jfk},
                {p: :p1, c: :c4, from: :jfk, to: :kfc},
                {p: :p1, c: :c4, from: :kfc, to: :sfo},
                {p: :p1, c: :c4, from: :kfc, to: :jfk},
                {p: :p1, c: :c4, from: :kfc, to: :kfc},
                {p: :p2, c: :c1, from: :sfo, to: :sfo},
                {p: :p2, c: :c1, from: :sfo, to: :jfk},
                {p: :p2, c: :c1, from: :sfo, to: :kfc},
                {p: :p2, c: :c1, from: :jfk, to: :sfo},
                {p: :p2, c: :c1, from: :jfk, to: :jfk},
                {p: :p2, c: :c1, from: :jfk, to: :kfc},
                {p: :p2, c: :c1, from: :kfc, to: :sfo},
                {p: :p2, c: :c1, from: :kfc, to: :jfk},
                {p: :p2, c: :c1, from: :kfc, to: :kfc},
                {p: :p2, c: :c2, from: :sfo, to: :sfo},
                {p: :p2, c: :c2, from: :sfo, to: :jfk},
                {p: :p2, c: :c2, from: :sfo, to: :kfc},
                {p: :p2, c: :c2, from: :jfk, to: :sfo},
                {p: :p2, c: :c2, from: :jfk, to: :jfk},
                {p: :p2, c: :c2, from: :jfk, to: :kfc},
                {p: :p2, c: :c2, from: :kfc, to: :sfo},
                {p: :p2, c: :c2, from: :kfc, to: :jfk},
                {p: :p2, c: :c2, from: :kfc, to: :kfc},
                {p: :p2, c: :c3, from: :sfo, to: :sfo},
                {p: :p2, c: :c3, from: :sfo, to: :jfk},
                {p: :p2, c: :c3, from: :sfo, to: :kfc},
                {p: :p2, c: :c3, from: :jfk, to: :sfo},
                {p: :p2, c: :c3, from: :jfk, to: :jfk},
                {p: :p2, c: :c3, from: :jfk, to: :kfc},
                {p: :p2, c: :c3, from: :kfc, to: :sfo},
                {p: :p2, c: :c3, from: :kfc, to: :jfk},
                {p: :p2, c: :c3, from: :kfc, to: :kfc},
                {p: :p2, c: :c4, from: :sfo, to: :sfo},
                {p: :p2, c: :c4, from: :sfo, to: :jfk},
                {p: :p2, c: :c4, from: :sfo, to: :kfc},
                {p: :p2, c: :c4, from: :jfk, to: :sfo},
                {p: :p2, c: :c4, from: :jfk, to: :jfk},
                {p: :p2, c: :c4, from: :jfk, to: :kfc},
                {p: :p2, c: :c4, from: :kfc, to: :sfo},
                {p: :p2, c: :c4, from: :kfc, to: :jfk},
                {p: :p2, c: :c4, from: :kfc, to: :kfc}]
    assert_equal expected, variables
  end

  def test_permutate_arguments_less_than_params
    params = parameters([[:p, :plane], [:c, :cargo], [:to, :airport]],
                        [:plane, :cargo, :airport])
    assert_equal [{}], params.permutate(four_arguments)
  end

  def test_pair_arguments
    params = parameters([[:p, :plane], [:to, :airport]], [:airport, :plane])
    assert_equal({p: :p1, to: :sfo}, params.pair([:p1, :sfo]))
  end

  def test_map_arguments_from_variables
    params = parameters([[:p, :plane], [:to, :airport]], [:plane, :airport])
    assert_equal([:p1, :sfo], params.arguments({p: :p1, to: :sfo}))
    assert_equal([:p1, nil], params.arguments({p: :p1}))
  end

  def test_propositionalize_should_eval_exps_in_precondition
    action = {
      name: :fly,
      parameters: [[:p, :plane], [:from, :airport], [:to, :airport]],
      precond: [[:at, :p, :from],
                [:!=, :from, :to]],
      effect: [
        [:at, :p, :to],
        [:-, :at, :p, :from]
      ]
    }
    params = parameters(action[:parameters], [:plane, :airport, :cargo])
    actions = params.propositionalize(action, [
                                        [:p1, :plane],
                                        [:sfo, :airport],
                                        [:jfk, :airport]
                                      ])
    assert_equal 2, actions.size
    assert_equal [literal([:at, :p1, :sfo])], actions[0][:precond]
    assert_equal [literal([:at, :p1, :jfk])], actions[1][:precond]
  end

  def test_propositionalize_should_ignore_action_having_conflict_precond
    action = {
      name: :fly,
      parameters: [[:p, :plane], [:from, :airport], [:to, :airport]],
      precond: [[:at, :p, :from],
                [:-, :at, :p, :to]],
      effect: [
        [:at, :p, :to],
        [:-, :at, :p, :from]
      ]
    }
    params = parameters(action[:parameters], [:plane, :airport, :cargo])
    actions = params.propositionalize(action, [
                                        [:p1, :plane],
                                        [:sfo, :airport],
                                        [:jfk, :airport]
                                      ])
    ret = actions.map{|a|a[:describe].call}
    assert_equal ["fly(p1 sfo jfk)", "fly(p1 jfk sfo)"].sort, ret.sort
  end

  def test_propositionalize_should_ignore_action_having_conflict_effect
    action = {
      name: :fly,
      parameters: [[:p, :plane], [:from, :airport], [:to, :airport]],
      precond: [[:at, :p, :from]],
      effect: [
        [:at, :p, :to],
        [:-, :at, :p, :from]
      ]
    }
    params = parameters(action[:parameters], [:plane, :airport, :cargo])
    actions = params.propositionalize(action, [
                                        [:p1, :plane],
                                        [:sfo, :airport],
                                        [:jfk, :airport]
                                      ])
    ret = actions.map{|a|a[:describe].call}
    assert_equal ["fly(p1 sfo jfk)", "fly(p1 jfk sfo)"].sort, ret.sort
  end

  def test_names
    params = parameters([[:p, :plane], [:to, :airport]], [:plane, :airport])
    assert_equal [:p, :to], params.names
  end

  def test_type_inhierencing
    action = {
      name: :load,
      parameters: [[:c, :cargo], [:p, :plane], [:a, :airport]],
      precond: [
        [:at, :c, :a],
        [:at, :p, :a]
      ],
      effect: [
        [:-, :at, :c, :a],
        [:in, :c, :p]
      ]
    }
    types = [
      [:cargo, :object],
      [:plane, :object],
      [:airport, :object],
      [:car, :cargo]
    ]
    params = parameters(action[:parameters], types)
    actions = params.propositionalize(action, [
                                        [:p1, :plane],
                                        [:sfo, :airport],
                                        [:modelx, :car],
                                        [:box, :cargo]
                                      ])
    assert_equal 2, actions.size
    assert_equal [literal([:at, :modelx, :sfo]),
                  literal([:at, :p1, :sfo])],
                 actions[0][:precond]
    assert_equal [literal([:at, :box, :sfo]),
                  literal([:at, :p1, :sfo])],
                 actions[1][:precond]
  end

  def test_handles_no_types_case
    action = {
      name: :fly,
      precond: [[:at, :sfo]],
      effect: [
        [:at, :jfk],
        [:-, :at, :sfo]
      ]
    }
    params = parameters(nil, nil)
    actions = params.propositionalize(action, [:sfo, :jfk])
    assert_equal 1, actions.size
    assert_equal [literal([:at, :sfo])], actions[0][:precond]
    assert_equal [literal([:at, :jfk]), literal([:-, :at, :sfo])],
                 actions[0][:effect]
  end

  def test_handles_no_inherent_types
    action = {
      name: :fly,
      precond: [[:at, :from], [:!=, :from, :to]],
      effect: [
        [:at, :to],
        [:-, :at, :from]
      ]
    }
    params = parameters([[:from, :airport], [:to, :airport]],
                        [:plane, :airport])
    objs = [[:sfo, :airport], [:jfk, :airport]]
    actions = params.propositionalize(action, objs)
    expected = [{
                  name: :fly,
                  describe: "fly(sfo jfk)",
                  precond: [literal([:at, :sfo])],
                  effect: [
                    literal([:at, :jfk]),
                    literal([:-, :at, :sfo])
                  ]
                },
                {
                  name: :fly,
                  describe: "fly(jfk sfo)",
                  precond: [literal([:at, :jfk])],
                  effect: [
                    literal([:at, :sfo]),
                    literal([:-, :at, :jfk])
                  ]
                }
               ]

    assert_equal 2, actions.size
    assert_equal expected[0][:name], actions[0][:name]
    assert_equal expected[0][:describe], actions[0][:describe].call
    assert_equal expected[0][:effect], actions[0][:effect]
    assert_equal expected[0][:precond], actions[0][:precond]

    assert_equal expected[1][:name], actions[1][:name]
    assert_equal expected[1][:describe], actions[1][:describe].call
    assert_equal expected[1][:effect], actions[1][:effect]
    assert_equal expected[1][:precond], actions[1][:precond]
  end

  def literal(lit)
    Longjing::Literal.create(lit)
  end

  def four_arguments
    [[:p1, :plane], [:p2, :plane], [:sfo, :airport], [:jfk, :airport]]
  end

  def six_arguments
    [[:p1, :plane], [:p2, :plane],
     [:sfo, :airport], [:jfk, :airport], [:kfc, :airport],
     [:c1, :cargo], [:c2, :cargo], [:c3, :cargo], [:c4, :cargo]]
  end
end
