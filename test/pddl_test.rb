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

  def test_parse_typing_for_domain_pddl
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

  def test_parse_typing_for_problem_pddl
    PDDL.parse(read('barman'))
    pddl = PDDL.parse(read("barman-p1-11-4-15"))
    expected = [["shaker1", "shaker"],
                ["left", "hand"],
                ["right", "hand"],
                ["shot1", "shot"],
                ["shot2", "shot"],
                ["shot3", "shot"],
                ["shot4", "shot"],
                ["shot5", "shot"],
                ["shot6", "shot"],
                ["shot7", "shot"],
                ["shot8", "shot"],
                ["shot9", "shot"],
                ["shot10", "shot"],
                ["shot11", "shot"],
                ["shot12", "shot"],
                ["shot13", "shot"],
                ["shot14", "shot"],
                ["shot15", "shot"],
                ["ingredient1", "ingredient"],
                ["ingredient2", "ingredient"],
                ["ingredient3", "ingredient"],
                ["ingredient4", "ingredient"],
                ["cocktail1", "cocktail"],
                ["cocktail2", "cocktail"],
                ["cocktail3", "cocktail"],
                ["cocktail4", "cocktail"],
                ["cocktail5", "cocktail"],
                ["cocktail6", "cocktail"],
                ["cocktail7", "cocktail"],
                ["cocktail8", "cocktail"],
                ["cocktail9", "cocktail"],
                ["cocktail10", "cocktail"],
                ["cocktail11", "cocktail"],
                ["dispenser1", "dispenser"],
                ["dispenser2", "dispenser"],
                ["dispenser3", "dispenser"],
                ["dispenser4", "dispenser"],
                ["l0", "level"],
                ["l1", "level"],
                ["l2", "level"]]
    assert_equal expected, pddl[:objects]
  end

  def test_should_raise_unknown_domain_error_when_parsing_a_problem_use_unknown_domain
    PDDL.domains.clear
    assert_raise UnknownDomain do
      PDDL.parse(read("barman-p1-11-4-15"))
    end
  end

  def test_parse_comments
    pddl = PDDL.parse(read('freecell'))
    assert pddl
    assert_equal 'freecell', pddl[:domain]
    assert_equal [:strips, :typing], pddl[:requirements]
    assert_equal ["card", "colnum", "cellnum", "num", "suit"], pddl[:types]
    assert_equal 10, pddl[:actions].size
  end

  def test_search_plan_for_typing_problem
    PDDL.parse(read('freecell'))
    pddl = PDDL.parse(read("freecell-f2-c2-s2-i1-02-12"))
    result = Longjing.plan(pddl)
    assert !result[:solution].nil?
    Longjing.validate!(Longjing.problem(pddl), result[:solution])
  end

  def read(name)
    f = File.expand_path("../domains/#{name}.pddl", __FILE__)
    if File.exist?(f)
      File.read(f)
    else
      f = File.expand_path("../problems/#{name}.pddl", __FILE__)
      if File.exist?(f)
        File.read(f)
      else
        f = File.expand_path("../#{name}.pddl", __FILE__)
        File.read(f)
      end
    end
  end

end
