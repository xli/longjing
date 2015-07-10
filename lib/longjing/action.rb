require 'longjing/literal'

module Longjing
  class Action
    attr_reader :name, :describe, :effect
    def initialize(hash)
      @name = hash[:name]
      @precond = Literal.list(hash[:precond])
      @effect = hash[:effect]
      @describe = hash[:describe]
    end

    def executable?(state)
      @precond.match?(state.raw)
    end

    def result(state)
      raw = @effect.inject(state.raw.dup) do |memo, effect|
        if effect.negative?
          memo.delete(effect.positive)
        else
          memo << effect
        end
      end
      State.new(raw, state.path + [describe])
    end
  end
end
