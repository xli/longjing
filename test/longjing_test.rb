require "test_helper"

class LongjingTest < Test::Unit::TestCase
  def test_blocks_world_planning
    problem = {
      init: [[:on, :A, :table],
             [:on, :B, :table],
             [:on, :C, :A],
             [:block, :A],
             [:block, :B],
             [:block, :C],
             [:clear, :B],
             [:clear, :C]],
      goal: [[:on, :A, :B], [:on, :B, :C]],
      actions: [
        {
          name: :move,
          arguments: [:b, :x, :y],
          precond: [[:on, :b, :x],
                    [:clear, :b],
                    [:clear, :y],
                    [:block, :b],
                    [:block, :y],
                    [:!=, :b, :x],
                    [:!=, :b, :y],
                    [:!=, :x, :y]],
          effect: [
            [:on, :b, :y],
            [:clear, :x],
            [:-, :on, :b, :x],
            [:-, :clear, :y]
          ]
        },
        {
          name: :moveToTable,
          arguments: [:b, :x],
          precond: [[:on, :b, :x],
                    [:block, :b],
                    [:clear, :b],
                    [:!= :b, :x]],
          effect: [
            [:on, :b, :table],
            [:clear, :x],
            [:-, :on, :b, :x]
          ]
        }
      ]
    }
    result = Longjing.plan(problem)

    assert result[:resolved]
    assert_equal [[:moveToTable, :C, :A], [:move, :B, :table, :C], [:move, :table, :B]], result[:sequence]
  end

  def test_cake_example_planning
    problem = {
      init: [[:have, :cake]],
      goal: [[:have, :cake], [:eaten, :cake]],
      actions: [
        {
          name: :eat,
          precond: [[:have, :cake]],
          effect: [[:-, :have, :cake], [:eaten, :cake]]
        },
        {
          name: :bake,
          precond: [[:-, :have, :cake]],
          effect: [[:have, :cake]]
        }
      ]
    }

    result = Longjing.plan(problem)
    assert result[:resolved]
    assert_equal [[:eat, :cake], [:bake, :cake]], result[:sequence]
  end

end
