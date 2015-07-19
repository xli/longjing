require 'longjing/literal'

module Longjing
  class Action
    attr_reader :precond, :effect, :name
    def initialize(hash)
      @hash = hash
      @name = @hash[:name]
      @precond = Literal.list(@hash[:precond])
      @effect = Literal.list(@hash[:effect])
    end

    def describe
      @describe ||= @hash[:describe].call
    end

    def to_s
      "Action[#{describe}, #{precond}, #{effect}]"
    end
  end
end
