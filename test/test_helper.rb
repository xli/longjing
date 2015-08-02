require 'pp'
require 'test-unit'
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "longjing"

Dir[File.expand_path('../problems/*.rb', __FILE__)].each do |f|
  require f
end

class Test::Unit::TestCase
  def blocksworld_rand_4_problem
    Longjing.pddl_problem(pddl_file('blocksworld-4ops'),
                          pddl_file("bw-rand-4"))
  end

  def blocksworld_rand_8_problem
    Longjing.pddl_problem(pddl_file('blocksworld-4ops'),
                          pddl_file("blocksworld-4ops-rand-8"))
  end

  def freecell_problem
    Longjing.pddl_problem(pddl_file('freecell'), pddl_file("freecell-f2-c2-s2-i1-02-12"))
  end

  def cake_problem
    Longjing.pddl_problem(pddl_file('cake'), pddl_file('cake-a'))
  end

  def cargo_transportation_problem
    Longjing.pddl_problem(pddl_file('cargo'), pddl_file('cargo-a'))
  end

  def fact(pred, objs)
    Longjing::PDDL::Fact[pred, objs]
  end

  def pddl_file(name)
    Dir[File.expand_path("../**/#{name}.pddl", __FILE__)].first
  end
end
