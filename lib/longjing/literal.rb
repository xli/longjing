module Longjing
  class Literal
    class List
      attr_reader :pos, :neg

      def initialize(literals)
        @pos = literals.select(&:positive?)
        @neg = literals.select(&:negative?).collect(&:positive)
      end

      def match?(set)
        pos_subset?(set) &&
          @neg.all?{|lit| !set.include?(lit)}
      end

      def pos_subset?(set)
        @pos.all?{|lit| set.include?(lit)}
      end

      def apply(set)
        ret = set.dup
        @pos.each { |lit| ret[lit] = true }
        @neg.each { |lit| ret.delete(lit) }
        ret
      end

      def to_s
        "[#{to_a.join(" ")}]"
      end

      def to_a
        @pos + @neg.map(&:negative)
      end
    end

    class << self
      def create(raw)
        @literals ||= {}
        @literals[raw] ||= Literal.new(raw)
      end

      def set(raw)
        ret = {}
        literals(raw).each do |l|
          ret[l] = true
        end
        ret
      end

      def list(raws)
        List.new(literals(raws))
      end

      def literals(raws)
        raws.map{|lit| lit.is_a?(Literal) ? lit : Literal.create(lit)}
      end
    end

    attr_reader :raw, :hash
    def initialize(raw)
      @raw = raw
      @hash = raw.hash
      @is_exp = inequal?
      @is_neg = :-.object_id == @raw[0].object_id
    end

    def positive
      @positive ||= @is_neg ? Literal.create(@raw[1..-1]) : self
    end

    def negative
      @negative ||= @is_neg ? self : Literal.create([:-].concat(@raw))
    end

    def positive?
      !@is_neg
    end

    def negative?
      @is_neg
    end

    def exp?
      @is_exp
    end

    def match?
      @raw[1] != @raw[2]
    end

    def to_s
      "(#{@raw.join(" ")})"
    end

    private
    def inequal?
      :!=.object_id == @raw[0].object_id
    end
  end
end
