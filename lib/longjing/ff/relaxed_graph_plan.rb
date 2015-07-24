module Longjing
  module FF
    class RelaxedGraphPlan
      class Action
        attr_accessor :counter, :difficulty, :layer
        attr_reader :count_target, :pre, :add, :action, :hash

        def initialize(action)
          @action = action
          @pre = @action.precond.pos
          @add = @action.effect.pos
          @count_target = @pre.size
          @hash = self.object_id
        end

        def describe
          @action.describe
        end

        def to_s
          "Action[#{describe}]"
        end
      end

      def initialize(problem)
        build(problem.to_h)
      end

      def action_id(describe)
        @actions.find{|a| a.describe == describe}
      end

      def layers(state)
        fact_layers = {}
        step = 0
        scheduled_facts = state.raw
        scheduled_actions = []
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
        goal = @goal.pos
        layered_actions = []
        loop do
          scheduled_facts.each do |lit|
            fact_layers[lit] = step
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
          break if goal.all? {|lit| fact_layers.has_key?(lit)}
          scheduled_facts = Set.new
          scheduled_actions.each do |action|
            layered_actions << action
            action.layer = step
            action.add.each do |lit|
              unless fact_layers.has_key?(lit)
                scheduled_facts << lit
              end
            end
          end
          scheduled_actions = []
          break if scheduled_facts.empty?
          step += 1
        end
        [fact_layers, layered_actions]
      end

      def extract(state, added_goals=[])
        fact_layers, layered_actions = layers(state)

        marks = Hash.new{|h,k| h[k]=Set.new}
        layer2facts = Hash.new{|h,k|h[k]=[]}
        @goal.pos.each do |lit|
          layer = fact_layers[lit]
          return nil if layer.nil?
          layer2facts[layer] << lit
        end

        # m = first layer contains all goals
        m = layer2facts.keys.max
        plan = []
        (1..m).to_a.reverse.each do |i|
          next unless layer2facts.has_key?(i)
          subplan = []
          layer2facts[i].each do |g|
            next if marks[g].include?(i)
            next unless actions = @add2actions[g]
            action = actions.select do |a|
              a.layer == i - 1
            end.min_by(&:difficulty)

            action.pre.each do |lit|
              if fact_layers[lit] != 0 && !marks[lit].include?(i - 1)
                layer2facts[fact_layers[lit]] << lit
              end
            end
            action.add.each do |lit|
              marks[lit] << i << (i - 1)
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
          helpful_actions = Set.new
          layer2facts[1].each do |lit|
            @add2actions[lit].each do |action|
              if action.layer == 0
                helpful_actions << action.action
              end
            end
          end
          [plan, helpful_actions.empty? ? nil : helpful_actions.to_a]
        end
      end

      private
      def build(problem)
        @goal = problem[:goal]
        @actions = problem[:actions].map do |action|
          Action.new(action)
        end
        @add2actions = {}
        @pre2actions = {}
        @actions.each do |action|
          action.pre.each do |lit|
            @pre2actions[lit] ||= []
            @pre2actions[lit] << action
          end
          action.add.each do |lit|
            @add2actions[lit] ||= []
            @add2actions[lit] << action
          end
        end
      end
    end
  end
end
