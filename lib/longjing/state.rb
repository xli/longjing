module Longjing
  class State
    attr_reader :raw, :path, :hash
    def initialize(raw, path=[])
      @raw = raw
      @path = path
      @hash = @raw.hash
    end

    def ==(state)
      return true if state.object_id == self.object_id
      return false if state.nil?
      @raw == state.raw
    end
    alias :eql? :==

    def to_s
      "{#{@raw.to_a.join(" ")}}"
    end
  end
end
