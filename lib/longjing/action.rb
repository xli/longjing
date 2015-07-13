require 'longjing/literal'

module Longjing
  class Action
    attr_reader :name, :describe, :effect, :precond
    def initialize(hash)
      @name = hash[:name]
      @precond = Literal.list(hash[:precond])
      @effect = Literal.list(hash[:effect])
      @describe = hash[:describe]
    end

    def executable?(state)
      @precond.match?(state.raw)
    end

    def result(state)
      raw = @effect.apply(state.raw)
      State.new(raw, state.path + [describe])
    end

    def to_s
      "Action[#{@describe}, #{@precond}, #{@effect}"
    end
  end
end
