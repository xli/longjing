require 'longjing/pddl.tab'

module Longjing
  class PDDL
    class << self
      def domains
        @domains ||= {}
      end
      def problems
        @problems ||= {}
      end

      def parse(pddl)
        eval(PDDL.new.parse(pddl))
      end

      def eval(pddl)
        if atom?(pddl)
          pddl
        elsif list?(pddl)
          pddl.map {|i| eval(i)}
        else
          first, *rest = pddl
          apply(first, rest)
        end
      end

      def apply(name, list)
        case name
        when 'define'
          type, name = list[0]
          store = type == 'domain' ? self.domains : self.problems
          store[name] = to_hash(eval(list[1..-1])).merge(type.to_sym => name)
        when :domain
          self.domains[list[0]].dup
        when :goal
          { goal: expand_value(eval(list[0])) }
        when :action
          details = to_hash(eval(list[1..-1].each_slice(2).to_a))
          [:actions, details.merge(name: list[0])]
        when :parameters
          { parameters: list[0] }
        when :precondition
          { precond: expand_value(list[0]) }
        when :goal, :effect
          { name => expand_value(list[0]) }
        when :requirements, :init, :objects, :predicates
          { name => list }
        when 'not'
          [:-, *eval(list[0])]
        when 'and'
          list.map do |item|
            eval(item)
          end
        else
          raise "Unexpected #{name.inspect} with #{list.inspect}"
        end
      end

      def atom?(list)
        list.all?{|i|i.is_a?(String)}
      end

      def list?(list)
        list.all?{|i|i.is_a?(Array)}
      end

      def expand_value(list)
        atom?(list) ? [list] : eval(list)
      end

      def to_hash(list)
        list.inject({}) do |memo, item|
          case item
          when Hash
            memo.merge(item)
          when Array
            name, value = item
            memo[name] = Array(memo[name]) << value
            memo
          else
            raise "Unexpected value: #{ret.inspect}"
          end
        end
      end
    end
  end
end
