require 'pp'
require 'test-unit'
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "longjing"

Dir[File.expand_path('../problems/*.rb', __FILE__)].each do |f|
  require f
end
