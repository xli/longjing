require 'longjing/pddl/parser.tab.rb'

module Longjing
  class Error < StandardError
  end

  class UnknownDomain < Error
  end

  class UnsupportedRequirements < Error
  end

  module PDDL
    module_function

    def domains
      @domains ||= {}
    end

    def parse(pddl)
      Parser.new.parse(pddl, self.domains)
    end
  end
end
