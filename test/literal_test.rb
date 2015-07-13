require "test_helper"

class LiteralTest < Test::Unit::TestCase
  include Longjing

  def test_create_should_reuse_instance_for_equal_raw_value
    a = Literal.create([:a])
    assert_equal [:a], a.raw
    assert_same a, Literal.create([:a])
    assert_same a.negative, Literal.create([:-, :a])

    b = Literal.create([:-, :b])
    assert_equal [:-, :b], b.raw
    assert_not_equal a, b
    assert_same b.positive, Literal.create([:b])
  end
end
