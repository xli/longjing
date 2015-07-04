require "test_helper"

class StateTest < Test::Unit::TestCase

  def test_hash_func
    a1 = Longjing::State.new([:a], [1])
    a2 = Longjing::State.new([:a], [2])
    b2 = Longjing::State.new([:b], [2])
    assert_equal a1, a2
    assert_not_equal a2, b2
    set = Set.new([a1, a2, b2])
    assert_equal 2, set.size
    assert_equal [[:a], [:b]], set.map(&:raw)
  end
end
