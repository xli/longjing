require "test_helper"

class PDDLDataStructureTest < Test::Unit::TestCase
  include Longjing::PDDL

  def test_type_parents
    computer = Type.new(:computer)
    mac = Type.new(:mac, computer)
    pc = Type.new(:pc, computer)
    macbook = Type.new(:macbook, mac)

    assert_equal nil, Type::OBJECT.parent
    assert_equal Type::OBJECT, computer.parent
    assert_equal computer, mac.parent
    assert_equal mac, macbook.parent
  end

  def test_type
    assert_equal Type.new(:computer).hash, Type.new(:computer).hash
    assert_not_equal Type.new(:computer).hash, Type.new(:mac).hash
    assert_not_equal Type.new(:computer), Type.new(:mac)
  end

  def test_obj_is_a_type
    computer = Type.new(:computer)
    mac = Type.new(:mac, computer)
    pc = Type.new(:pc, computer)
    macbook = Type.new(:macbook, mac)

    assert Obj.new(:a).is_a?(Type::OBJECT)
    assert Obj.new(:a, mac).is_a?(computer)
    assert Obj.new(:a, mac).is_a?(mac)
    assert Obj.new(:a, macbook).is_a?(mac)
    assert Obj.new(:a, macbook).is_a?(computer)
    assert Obj.new(:a, macbook).is_a?(Type::OBJECT)
    assert !Obj.new(:a, macbook).is_a?(pc)
  end

  def test_var
    computer = Type.new(:computer)
    mac = Type.new(:mac, computer)
    pc = Type.new(:pc, computer)
    macbook = Type.new(:macbook, mac)

    assert_equal Var.new(:x, mac).hash, Var.new(:x, mac).hash

    assert_not_equal Var.new(:x, mac), Var.new(:y, mac)
    assert_not_equal Var.new(:x, mac), Var.new(:x, pc)
    assert_not_equal Var.new(:x, mac), nil
    assert_not_equal nil, Var.new(:x, mac)
  end

  def test_substitute_variables
    a = Obj.new(:a)
    b = Obj.new(:b)
    x = Var.new(:'?x')
    y = Var.new(:'?y')
    lit = Fact.new(:on, [a])
    ret = lit.substitute({x => a, y => b})
    assert_same lit, ret
  end

  def test_substitute_variables_for_not
    a = Obj.new(:a)
    b = Obj.new(:b)
    x = Var.new(:'?x')
    y = Var.new(:'?y')
    pred = Predicate.new(:on, [x, y])
    lit = Formula.new(pred, [x, y])
    not_pred = Not.new(lit)
    ret = not_pred.substitute({x => a, y => b})
    assert_equal "(not (on a b))", ret.to_s
  end

  def test_substitute_variables_for_and
    a = Obj.new(:a)
    b = Obj.new(:b)
    x = Var.new(:'?x')
    y = Var.new(:'?y')
    on = Predicate.new(:on, [x, y])
    clear = Predicate.new(:clear, [x])
    lit1 = Formula.new(on, [x, y])
    lit2 = Formula.new(clear, [x])
    preds = And.new([lit1, lit2])
    ret = preds.substitute({x => a, y => b})
    assert_equal "(and (on a b) (clear a))", ret.to_s
  end

  def test_applicable
    a = Obj.new(:a)
    b = Obj.new(:b)
    x = Var.new(:'?x')
    y = Var.new(:'?y')

    on = Predicate.new(:on, [x, y])
    clear = Predicate.new(:clear, [x])

    on_a_b = Fact.new(on, [a, b])
    clear_a = Fact.new(clear, [a])

    assert on_a_b.applicable?([on_a_b].to_set)
    assert on_a_b.applicable?([on_a_b, clear_a].to_set)
    assert clear_a.applicable?([on_a_b, clear_a].to_set)
    assert !on_a_b.applicable?([clear_a].to_set)

    assert !Not.new(on_a_b).applicable?([on_a_b].to_set)
    assert Not.new(on_a_b).applicable?([].to_set)
    assert Not.new(on_a_b).applicable?([clear_a].to_set)

    lits = And.new([on_a_b, clear_a])
    assert lits.applicable?([on_a_b, clear_a].to_set)
    assert !lits.applicable?([on_a_b].to_set)
    assert !lits.applicable?([clear_a].to_set)

    lits = And.new([on_a_b, Not.new(clear_a)])
    assert !lits.applicable?([on_a_b, clear_a].to_set)
    assert lits.applicable?([on_a_b].to_set)
    assert !lits.applicable?([clear_a].to_set)
  end

  def test_apply
    a = Obj.new(:a)
    b = Obj.new(:b)
    x = Var.new(:'?x')
    y = Var.new(:'?y')

    on = Predicate.new(:on, [x, y])
    clear = Predicate.new(:clear, [x])

    on_a_b = Fact.new(on, [a, b])
    clear_a = Fact.new(clear, [a])

    assert_equal [on_a_b], on_a_b.apply([])
    assert_equal [clear_a, on_a_b], on_a_b.apply([clear_a])

    ret = []
    Not.new(on_a_b).apply(ret)
    assert_equal [], ret

    ret = [clear_a, on_a_b]
    Not.new(on_a_b).apply(ret)
    assert_equal [clear_a], ret
  end

end
