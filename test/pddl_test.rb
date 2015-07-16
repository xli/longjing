require "test_helper"

class PDDLTest < Test::Unit::TestCase
  include Longjing

  def test_parse_domain
    pddl = PDDL.parse(read('blocksworld-4ops'))
    expected = {
      :domain => 'blocksworld',
      :requirements => [:strips],
      :predicates => [],
      :actions => [
        {name: "pickup",
         parameters: ["?ob"],
         precond: [["clear", "?ob"], ["on-table", "?ob"], ["arm-empty"]],
         effect: [["holding", "?ob"],
                  [:-, "clear", "?ob"],
                  [:-, "on-table", "?ob"],
                  [:-, "arm-empty"]]},
        {name: "putdown",
         parameters: ["?ob"],
         precond: [["holding", "?ob"]],
         effect: [["clear", "?ob"],
                  ["arm-empty"],
                  ["on-table", "?ob"],
                  [:-, "holding", "?ob"]]},
        {name: "stack",
         parameters: ["?ob", "?underob"],
         precond: [["clear", "?underob"], ["holding", "?ob"]],
         effect:
           [
             ["arm-empty"],
             ["clear", "?ob"],
             ["on", "?ob", "?underob"],
             [:-, "clear", "?underob"],
             [:-, "holding", "?ob"]]},
        {name: "unstack",
         parameters: ["?ob", "?underob"],
         precond: [["on", "?ob", "?underob"], ["clear", "?ob"], ["arm-empty"]],
         effect: [
           ["holding", "?ob"],
           ["clear", "?underob"],
           [:-, "on", "?ob", "?underob"],
           [:-, "clear", "?ob"],
           [:-, "arm-empty"]]
        }
      ]
    }

    assert_equal expected.size, pddl.size
    assert_equal expected[:requirements], pddl[:requirements]
    assert_equal expected[:actions].size, pddl[:actions].size
    assert_equal expected[:actions][0], pddl[:actions][0]
    assert_equal expected[:actions][1], pddl[:actions][1]
  end

  def test_parse_problem_pddl
    PDDL.parse(read('blocksworld-4ops'))
    pddl = PDDL.parse(read("blocksworld-4ops-rand-8"))
    expected = {
      :problem => "BW-rand-8",
      :objects => ["b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8"],
      :init =>
      [["arm-empty"],
       ["on-table", "b1"],
       ["on-table", "b2"],
       ["on-table", "b3"],
       ["on", "b4", "b7"],
       ["on", "b5", "b8"],
       ["on", "b6", "b4"],
       ["on", "b7", "b3"],
       ["on", "b8", "b6"],
       ["clear", "b1"],
       ["clear", "b2"],
       ["clear", "b5"]],
      :goal=>
      [["on", "b1", "b5"],
       ["on", "b2", "b7"],
       ["on", "b3", "b2"],
       ["on", "b4", "b3"],
       ["on", "b6", "b8"],
       ["on", "b7", "b6"]]}.merge(PDDL.domains['blocksworld'])
    assert_equal expected, pddl
  end

  def test_search_plan
    PDDL.parse(read('blocksworld-4ops'))
    pddl = PDDL.parse(read("blocksworld-4ops-rand-8"))
    result = Longjing.plan(pddl)
    assert !result[:solution].nil?
    Longjing.validate!(Longjing.problem(pddl), result[:solution])
  end

  def test_parse_typing
    pddl = PDDL.parse(read('barman'))
    expected = [['hand', 'object'],
                ['level', 'object'],
                ['beverage', 'object'],
                ['dispenser', 'object'],
                ['container', 'object'],
                ["ingredient", 'beverage'],
                ["cocktail", 'beverage'],
                ['shot', 'container'],
                ['shaker', 'container']]
    assert_equal expected, pddl[:types]

    expected = [['?h', 'hand'],
                ['?c', 'container']]
    assert_equal 'grasp', pddl[:actions][0][:name]
    assert_equal expected, pddl[:actions][0][:parameters]

    assert_equal 'fill-shot', pddl[:actions][2][:name]
  end

  def read(name)
    f = File.expand_path("../domains/#{name}.pddl", __FILE__)
    if File.exist?(f)
      File.read(f)
    else
      f = File.expand_path("../problems/#{name}.pddl", __FILE__)
      File.read(f)
    end
  end

end
