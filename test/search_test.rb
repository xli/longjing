require "test_helper"

class SearchTest < Test::Unit::TestCase

  def test_state
    a1 = Longjing::Search::State.new([:a], [1])
    a2 = Longjing::Search::State.new([:a], [2])
    b2 = Longjing::Search::State.new([:b], [2])
    assert_equal a1, a2
    assert_not_equal a2, b2
    set = Set.new([a1, a2, b2])
    assert_equal 2, set.size
    assert_equal [[:a], [:b]], set.map(&:raw)
  end

  def test_breadth_first_search
    search = Longjing::Search.new(:breadth_first)
    @goal = :a
    ret = search.resolve(self)
    assert_equal [], ret[:solution]
    assert_equal [], ret[:frontier]
    assert_equal [:a], ret[:explored]

    @goal = :g
    ret = search.resolve(self)
    solution = [[:move, :a, :d], [:move, :d, :g]]
    assert_equal solution, ret[:solution]
    assert_equal [:h], ret[:frontier]
    assert_equal [:a, :b, :c, :d, :e, :f, :g], ret[:explored]

    @goal = :h
    ret = search.resolve(self)
    solution = [[:move, :a, :c], [:move, :c, :e], [:move, :e, :h]]
    assert_equal solution, ret[:solution]
    assert_equal [], ret[:frontier]
    assert_equal [:a, :b, :c, :d, :e, :f, :g, :h], ret[:explored]
  end

  def test_should_raise_correct_error_info_when_given_unknown_strategy
    assert_raise RuntimeError do
      Longjing::Search.new(:something)
    end
  end
  # problem interface

  # ret: state
  def initial
    :a
  end

  # ret: boolean
  def goal?(state)
    @goal == state
  end

  # ret: [action]
  def actions(state)
    map = {
      a: [:b, :c, :d],
      b: [:a],
      c: [:e, :f],
      d: [:g],
      e: [:h],
      f: [:h],
      g: [:h],
      h: []
    }
    map[state].map {|to| {name: :move, to: to}}
  end

  # ret: [action-description]
  def describe(action, state)
    [action[:name], state, action[:to]]
  end

  # ret: state
  def result(action, state)
    action[:to]
  end
end
