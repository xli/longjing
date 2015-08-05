module Longjing
  module PDDL
    class Literal
      def applicable?(set)
        raise "Unsupported operation"
      end

      def apply(set)
        raise "Unsupported operation"
      end

      def substitute(variables)
        raise "Unsupported operation"
      end

      def to_a
        [self]
      end
    end

    class Empty < Literal
      def applicable?(set)
        true
      end

      def apply(set)
      end

      def substitute(variables)
        self
      end

      def to_s
        "()"
      end

      def inspect
        "<empty>"
      end
    end
    EMPTY = Empty.new

    class Fact < Literal
      @@insts = {}
      class << self
        def [](*args)
          @@insts[args] ||= new(*args)
        end
      end

      attr_reader :hash

      def initialize(pred, objs)
        @pred = pred
        @objs = objs
        @hash = [pred, objs].hash
      end

      def applicable?(set)
        set.include?(self)
      end

      def apply(set)
        set << self
      end

      def substitute(variables)
        self
      end

      def to_s
        "(#{[@pred.name, *@objs.map(&:name)].join(' ')})"
      end

      def inspect
        "(fact #{[@pred.name, *@objs].join(' ')})"
      end
    end

    class Formula < Literal
      attr_reader :pred, :vars, :hash
      def initialize(pred, vars)
        @pred = pred
        @vars = vars
        @hash = [pred, vars].hash
      end

      def substitute(variables)
        Fact[@pred, @vars.map{|v| variables[v]}]
      end

      def to_s
        "(#{[@pred.name, *@vars].join(' ')})"
      end

      def inspect
        "(formula #{to_s})"
      end
    end

    class Not < Literal
      @@insts = {}
      class << self
        def [](lit)
          @@insts[lit] ||= new(lit)
        end
      end

      attr_reader :literal, :hash

      def initialize(literal)
        @literal = literal
        @hash = literal.hash
      end

      def applicable?(set)
        !set.include?(@literal)
      end

      def apply(set)
        set.delete(@literal)
      end

      def substitute(variables)
        ret = @literal.substitute(variables)
        if ret.nil?
          EMPTY
        elsif ret == EMPTY
          nil
        else
          Not[ret]
        end
      end

      def to_s
        "(not #{@literal})"
      end

      def inspect
        "(not #{@literal.inspect})"
      end
    end

    class Equal < Literal
      attr_reader :left, :right
      def initialize(left, right)
        @left, @right = left, right
      end

      def substitute(variables)
        variables[@left] == variables[@right] ? EMPTY : nil
      end

      def to_s
        "(= #{@left} #{@right})"
      end

      def inspect
        "(= #{@left.inspect} #{@right.inspect})"
      end
    end

    class EqualFormula < Equal
      def substitute(variables)
        @left == @right ? EMPTY : nil
      end
    end

    class And < Literal
      attr_reader :literals

      def initialize(literals)
        @literals = literals
      end

      def applicable?(set)
        @literals.all? do |lit|
          lit.applicable?(set)
        end
      end

      def apply(set)
        ret = set.dup
        @literals.each do |lit|
          lit.apply(ret)
        end
        ret
      end

      def substitute(variables)
        ret = []
        @literals.each do |lit|
          n = lit.substitute(variables)
          return nil if n.nil?
          next if n == EMPTY
          ret << n
        end
        if ret.empty?
          nil
        elsif ret.size == 1
          ret[0]
        else
          And.new(ret)
        end
      end

      def to_a
        @literals
      end

      def to_s
        "(and #{@literals.map(&:to_s).join(" ")})"
      end

      def inspect
        "(and #{@literals.map(&:inspect).join(" ")})"
      end
    end
  end
end
