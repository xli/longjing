require 'pp'
require 'test-unit'
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "longjing"

Dir[File.expand_path('../problems/*.rb', __FILE__)].each do |f|
  require f
end

class Test::Unit::TestCase
  def read_pddl(name)
    f = pddl_file(name)
    if File.exist?(f)
      File.read(f)
    end
  end

  def pddl_file(name)
    Dir[File.expand_path("../**/#{name}.pddl", __FILE__)].first
  end
end
