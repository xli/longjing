require 'set'

module Longjing
  class Literal
    class List
      def initialize(literals)
        @pos = literals.select(&:positive?)
        @neg = literals.select(&:negative?).collect(&:positive)
      end

      def match?(set)
        @pos.all?{|lit| set.include?(lit)} &&
          @neg.all?{|lit| !set.include?(lit)}
      end
    end

    class << self
      def set(raw)
        literals(raw).to_set
      end

      def list(raws)
        List.new(literals(raws))
      end

      def literals(raws)
        raws.map{|lit| lit.is_a?(Literal) ? lit : Literal.new(lit)}
      end
    end

    attr_reader :raw, :positive, :hash
    def initialize(raw)
      @raw = raw
      @hash = raw.hash
    end

    def positive
      @positive ||= negative? ? Literal.new(@raw[1..-1]) : self
    end

    def negative
      @negative ||= negative? ? self : Literal.new([:-].concat(@raw))
    end

    def positive?
      !negative?
    end

    def negative?
      @raw[0] == :-
    end

    def exp?
      inequal?
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

    def inspect
      "Literal#{@raw.inspect}"
    end
  end
end
