module Longjing
  class Literal
    attr_reader :raw, :positive, :hash
    def initialize(raw)
      @raw = raw
      @hash = raw.hash
      @positive = negative? ? Literal.new(@raw[1..-1]) : self
    end

    def negative?
      @raw[0] == :-
    end

    def inequal?
      @raw[0] == :!=
    end

    def match?
      @raw[1] != @raw[2]
    end

    def ==(literal)
      if literal.is_a?(Literal)
        @raw == literal.raw
      else
        @raw == literal
      end
    end
    alias :eql? :==
  end
end