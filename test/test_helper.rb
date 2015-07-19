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
