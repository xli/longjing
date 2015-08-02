require "test_helper"

class PDDLParserTest < Test::Unit::TestCase
  include Longjing

  def teardown
    PDDL.domains.clear
  end

  def test_parse_empty_action_content
    domain = PDDL.parse(<<-PDDL)
(define (domain cargo)
  (:types cargo plane airport)
  (:predicates (at ?p - plane ?a - airport)
               (in ?c - cargo ?p - plane))
  (:action empty
      :parameters ()
      :precondition ()
      :effect ()))
PDDL
    assert_equal [], domain[:actions][0].params
    assert_equal PDDL::EMPTY, domain[:actions][0].precond
    assert_equal PDDL::EMPTY, domain[:actions][0].effect
  end

  def test_parse_no_type_domain_blocksworld_4ops
    pddl = pddl(pddl_file('blocksworld-4ops'))
    assert_equal 4, pddl.size
    assert_equal :blocksworld, pddl[:domain]
    assert_equal [:strips], pddl[:requirements]
    assert_equal "(clear ?x - object) (on-table ?x - object) (arm-empty) (holding ?x - object) (on ?x - object ?y - object)", pddl[:predicates].join(" ")
    assert_equal 4, pddl[:actions].size

    action = pddl[:actions][0]
    assert_equal :pickup, action.name
    assert_equal 1, action.params.size
    assert_equal "?ob - object", action.params[0].to_s
    precond = "(and (clear ?ob - object) (on-table ?ob - object) (arm-empty))"
    assert_equal precond, action.precond.to_s
    effect = "(and (holding ?ob - object) (not (clear ?ob - object)) (not (on-table ?ob - object)) (not (arm-empty)))"
    assert_equal effect, action.effect.to_s

    action = pddl[:actions][1]
    assert_equal :putdown, action.name
    assert_equal 1, action.params.size
    assert_equal "?ob - object", action.params[0].to_s
    precond = "(holding ?ob - object)"
    assert_equal precond, action.precond.to_s
    effect =
      "(and (clear ?ob - object) (arm-empty) (on-table ?ob - object) (not (holding ?ob - object)))"
    assert_equal effect, action.effect.to_s

    action = pddl[:actions][2]
    assert_equal :stack, action.name
    assert_equal 2, action.params.size
    assert_equal "?ob - object", action.params[0].to_s
    assert_equal "?underob - object", action.params[1].to_s

    precond = "(and (clear ?underob - object) (holding ?ob - object))"
    assert_equal precond, action.precond.to_s
    effect =
      "(and (arm-empty) (clear ?ob - object) (on ?ob - object ?underob - object) (not (clear ?underob - object)) (not (holding ?ob - object)))"
    assert_equal effect, action.effect.to_s

    action = pddl[:actions][3]
    assert_equal :unstack, action.name
    assert_equal 2, action.params.size
    assert_equal "?ob - object", action.params[0].to_s
    assert_equal "?underob - object", action.params[1].to_s

    precond =
      "(and (on ?ob - object ?underob - object) (clear ?ob - object) (arm-empty))"
    assert_equal precond, action.precond.to_s
    effect =
      "(and (holding ?ob - object) (clear ?underob - object) (not (on ?ob - object ?underob - object)) (not (clear ?ob - object)) (not (arm-empty)))"
    assert_equal effect, action.effect.to_s
  end

  def test_parse_blocksworld_4ops_problem
    pddl = blocksworld_rand_4_problem
    assert_equal 8, pddl.size
    assert_equal [:domain, :requirements, :predicates, :actions,
                  :problem, :objects, :goal, :init].sort,
                 pddl.keys.sort

    assert_equal :"BW-rand-4", pddl[:problem]
    assert_equal :blocksworld, pddl[:domain]
    assert_equal "b1 - object, b2 - object, b3 - object, b4 - object", pddl[:objects].join(', ')

    init =
      "(fact arm-empty) (fact on b1 - object b2 - object) (fact on b2 - object b4 - object) (fact on-table b3 - object) (fact on-table b4 - object) (fact clear b1 - object) (fact clear b3 - object)"
    assert_equal init, pddl[:init].map(&:inspect).join(" ")
    goal =
      '(and (fact on b1 - object b2 - object) (fact on b3 - object b4 - object) (fact on b4 - object b1 - object))'
    assert_equal goal, pddl[:goal].inspect

    assert_equal 4, pddl[:actions].size
  end

  def test_parse_type_inhierencing_domain_barman
    pddl = pddl(pddl_file('barman'))
    assert_equal 5, pddl.size
    types = []
    types << 'hand - object'
    types << 'level - object'
    types << 'beverage - object'
    types << 'dispenser - object'
    types << 'container - object'
    types << 'ingredient - beverage - object'
    types << 'cocktail - beverage - object'
    types << 'shot - container - object'
    types << 'shaker - container - object'

    assert_equal types, pddl[:types].map(&:to_s)
    assert_equal 12, pddl[:actions].size

    action = pddl[:actions][0]
    assert_equal :grasp, action.name
    assert_equal "?h - hand - object ?c - container - object", action.params.join(' ')

    assert_equal :'fill-shot', pddl[:actions][2].name
  end

  def test_parse_barman_problem
    pddl = pddl_problem(pddl_file('barman'), pddl_file("barman-p1-11-4-15"))
    assert_equal 9, pddl.size

    objs = []
    objs << "shaker1 - shaker - container - object"
    objs << "left - hand - object"
    objs << "right - hand - object"
    objs << "shot1 - shot - container - object"
    objs << "shot2 - shot - container - object"
    objs << "shot3 - shot - container - object"
    objs << "shot4 - shot - container - object"
    objs << "shot5 - shot - container - object"
    objs << "shot6 - shot - container - object"
    objs << "shot7 - shot - container - object"
    objs << "shot8 - shot - container - object"
    objs << "shot9 - shot - container - object"
    objs << "shot10 - shot - container - object"
    objs << "shot11 - shot - container - object"
    objs << "shot12 - shot - container - object"
    objs << "shot13 - shot - container - object"
    objs << "shot14 - shot - container - object"
    objs << "shot15 - shot - container - object"
    objs << "ingredient1 - ingredient - beverage - object"
    objs << "ingredient2 - ingredient - beverage - object"
    objs << "ingredient3 - ingredient - beverage - object"
    objs << "ingredient4 - ingredient - beverage - object"
    objs << "cocktail1 - cocktail - beverage - object"
    objs << "cocktail2 - cocktail - beverage - object"
    objs << "cocktail3 - cocktail - beverage - object"
    objs << "cocktail4 - cocktail - beverage - object"
    objs << "cocktail5 - cocktail - beverage - object"
    objs << "cocktail6 - cocktail - beverage - object"
    objs << "cocktail7 - cocktail - beverage - object"
    objs << "cocktail8 - cocktail - beverage - object"
    objs << "cocktail9 - cocktail - beverage - object"
    objs << "cocktail10 - cocktail - beverage - object"
    objs << "cocktail11 - cocktail - beverage - object"
    objs << "dispenser1 - dispenser - object"
    objs << "dispenser2 - dispenser - object"
    objs << "dispenser3 - dispenser - object"
    objs << "dispenser4 - dispenser - object"
    objs << "l0 - level - object"
    objs << "l1 - level - object"
    objs << "l2 - level - object"

    assert_equal objs, pddl[:objects].map(&:to_s)
  end

  def test_should_raise_unknown_domain_error_when_parsing_a_problem_use_unknown_domain
    PDDL.domains.clear
    assert_raise UnknownDomain do
      pddl(pddl_file("barman-p1-11-4-15"))
    end
  end

  def test_parse_comments
    pddl = pddl(pddl_file('freecell'))
    assert pddl
    assert_equal :freecell, pddl[:domain]
    assert_equal [:strips, :typing], pddl[:requirements]
    assert_equal ['card - object', 'colnum - object',
                  'cellnum - object', 'num - object', 'suit - object'], pddl[:types].map(&:to_s)
    assert_equal 10, pddl[:actions].size
  end

  def test_raise_error_on_unsupported_requirements
    assert_raise UnsupportedRequirements do
      PDDL.parse(<<-PDDL)
(define (domain cargo)
  (:requirements :fluents)
  (:types cargo plane airport)
  (:predicates (at ?p - plane ?a - airport)
               (in ?c - cargo ?p - plane))
  (:action empty
      :parameters ()
      :precondition ()
      :effect ()))
PDDL
    end
  end
end
