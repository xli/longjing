module Longjing
  module FF
    class RelaxedGraphPlan
      attr_reader :actions

      def initialize(cg)
        @actions = cg.actions
        @add2actions = cg.add2actions
        @pre2actions = cg.pre2actions
      end

      def layers(goal, state)
        step = 0
        scheduled_facts = state.raw.keys
        scheduled_actions = []
        Literal.instances.each do |lit|
          lit.tmp = nil
        end
        @actions.each do |action|
          action.counter = 0
          action.layer = Float::INFINITY
          if action.pre.empty?
            action.difficulty = 0
            scheduled_actions << action
          else
            action.difficulty = Float::INFINITY
          end
        end
        loop do
          scheduled_facts.each do |lit|
            next unless lit.tmp.nil?
            lit.tmp = step
            if actions = @pre2actions[lit]
              actions.each do |action|
                next if action.counter == action.count_target
                action.counter += 1
                if action.counter == action.count_target
                  action.difficulty = step
                  scheduled_actions << action
                end
              end
            end
          end
          break unless goal.any? {|lit| lit.tmp.nil?}
          scheduled_facts = []
          scheduled_actions.each do |action|
            action.layer = step
            action.add.each do |lit|
              if lit.tmp.nil?
                scheduled_facts << lit
              end
            end
          end
          scheduled_actions = []
          break if scheduled_facts.empty?
          step += 1
        end
      end

      def extract(goal, state, added_goals=[])
        layers(goal, state)
        goal_layers = goal.map(&:tmp)
        return nil if goal_layers.any?(&:nil?)
        # m = first layer contains all goals
        m = goal_layers.max

        marks = Hash.new{|h,k| h[k]={}}
        layer2facts = Array.new(m + 1) { [] }

        goal.each do |lit|
          layer2facts[lit.tmp] << lit
        end

        plan = []
        (1..m).to_a.reverse.each do |i|
          subplan = []
          layer2facts[i].each do |g|
            next if marks[g].include?(i)
            next unless actions = @add2actions[g]
            action = actions.select do |a|
              a.layer == i - 1
            end.min_by(&:difficulty)

            action.pre.each do |lit|
              if lit.tmp != 0 && !marks[lit].include?(i - 1)
                layer2facts[lit.tmp] << lit
              end
            end
            action.add.each do |lit|
              marks[lit][i] = true
              marks[lit][i-1] = true
            end
            unless added_goals.empty?
              action.action.effect.neg.each do |lit|
                if added_goals.include?(lit)
                  return nil
                end
              end
            end

            subplan << action
          end
          unless subplan.empty?
            plan << subplan
          end
        end
        if plan.empty?
          [plan]
        else
          helpful_actions = {}
          layer2facts[1].each do |lit|
            @add2actions[lit].each do |action|
              if action.layer == 0
                helpful_actions[action.action] = true
              end
            end
          end
          [plan, helpful_actions.empty? ? nil : helpful_actions.keys]
        end
      end
    end
  end
end
