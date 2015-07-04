require "test_helper"

class ParametersTest < Test::Unit::TestCase
  include Longjing

  def test_no_typing
    params = parameters([[:p, nil], [:to, nil]])
    variables = params.permutate([[:p1, nil], [:p2, nil],
                                  [:sfo, nil], [:jfk, nil]])
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
    params = parameters([[:p, :plane]])
    variables = params.permutate(four_arguments)
    expected = [
      {p: :p1},
      {p: :p2}
    ]
    assert_equal expected, variables
  end

  def test_permutate_two_params
    params = parameters([[:p, :plane], [:to, :airport]])
    variables = params.permutate(four_arguments)
    assert_equal 4, variables.size
    expected = [{p: :p1, to: :sfo},
                {p: :p1, to: :jfk},
                {p: :p2, to: :sfo},
                {p: :p2, to: :jfk}]
    assert_equal expected, variables
  end

  def test_permutate_dup_types_params
    params = parameters([[:p, :plane], [:from, :airport], [:to, :airport]])
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
                         [:from, :airport], [:to, :airport]])
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
    params = parameters([[:p, :plane], [:c, :cargo], [:to, :airport]])
    assert_equal [{}], params.permutate(four_arguments)
  end

  def test_pair_arguments
    params = parameters([[:p, :plane], [:to, :airport]])
    assert_equal({p: :p1, to: :sfo}, params.pair([:p1, :sfo]))
  end

  def test_map_arguments_from_variables
    params = parameters([[:p, :plane], [:to, :airport]])
    assert_equal([:p1, :sfo], params.arguments({p: :p1, to: :sfo}))
    assert_equal([:p1, nil], params.arguments({p: :p1}))
  end

  def test_names
    params = parameters([[:p, :plane], [:to, :airport]])
    assert_equal [:p, :to], params.names
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
