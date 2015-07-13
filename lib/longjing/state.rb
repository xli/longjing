module Longjing
  class State
    attr_reader :raw, :path, :hash
    def initialize(raw, path=[])
      @raw = raw
      @path = path
      @hash = @raw.hash
    end

    def include?(lit)
      raw.include?(lit)
    end

    def ==(state)
      state && @raw == state.raw
    end
    alias :eql? :==

    def to_s
      "State[#{@raw.to_a.map(&:raw).inspect}, #{@path.inspect}]"
    end
  end
end
