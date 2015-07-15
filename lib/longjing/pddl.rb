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
        eval(PDDL.new.parse(pddl), {})
      end

      def eval(pddl, context)
        if atom?(pddl)
          pddl
        else
          first, *rest = pddl
          apply(first, rest, context)
        end
      end

      def apply(name, list, context)
        case name
        when 'define'
          type, name = list[0]
          store = case type
                  when 'domain'
                    context.merge!(domain_name: name, actions: [])
                    self.domains
                  else
                    context.merge!(problem_name: name)
                    self.problems
                  end
          store[name] = expand_list(list[1..-1], context).merge(context)
        when :domain
          self.domains[list[0]].dup
        when :objects
          { objects: list }
        when :init
          { init: expand_value(list, context) }
        when :goal
          { goal: expand_value(list, context) }
        when :requirements
          { requirements: list }
        when :predicates
          {}
        when :action
          details = expand_list(Hash[*list[1..-1]].to_a, context)
          context[:actions] << {name: list[0]}.merge(details)
          {}
        when :parameters
          { parameters: list[0] }
        when :precondition
          { precond: expand_value(list, context) }
        when :effect
          { effect: expand_value(list, context) }
        when 'not'
          [:-, *eval(list[0], context)]
        when 'and'
          list.map do |item|
            eval(item, context)
          end
        else
          raise "Unsupported op: #{name} with #{list.inspect}"
        end
      end

      def expand_list(list, context)
        list.inject({}) do |memo, item|
          memo.merge(eval(item, context))
        end
      end

      def expand_value(list, context)
        atom?(list[0]) ? list : eval(list[0], context)
      end

      def atom?(list)
        !list.any?{|i| i.is_a?(Array) || i.is_a?(Symbol)}
      end
    end
  end
end
