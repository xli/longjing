require "test_helper"

class SearchTest < Test::Unit::TestCase

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

  def state(raw, path=[])
    Longjing.state(raw, path)
  end

  # problem interface

  # ret: state
  def initial
    state(:a)
  end

  # ret: boolean
  def goal?(state)
    state(@goal) == state
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
    map[state.raw].map {|to| {name: :move, to: to}}
  end

  # ret: [action-description]
  def describe(action, state)
    [action[:name], state.raw, action[:to]]
  end

  # ret: state
  def result(action, state)
    state(action[:to], state.path + [describe(action, state)])
  end
end
