module Longjing
  class State
    attr_reader :raw, :path, :hash
    attr_accessor :cost

    def initialize(raw, path=[])
      @raw = raw
      @path = path
      @hash = @raw.hash
      @cost = 0
    end

    def ==(state)
      return true if state.object_id == self.object_id
      @raw == state.raw
    end
    alias :eql? :==

    def to_s
      "{#{@raw.to_a.join(" ")}}"
    end

    def <=>(s)
      @cost <=> s.cost
    end
  end
end
