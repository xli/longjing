module Longjing
  module FF
    class RelaxedGraphPlan
      class Action
        attr_accessor :counter, :difficulty, :count_target, :pre, :add
        def initialize(action)
          @action = action
          @pre = @action.precond.pos
          @add = @action.effect.pos
          @count_target = @pre.size
        end

        def name
          @action.describe
        end

        def to_s
          "Action[#{name}]"
        end
      end

      def initialize(problem)
        build(problem.to_h)
      end

      def action_id(name)
        @actions.find{|a|a.name == name}.object_id
      end

      def distance(state)
        if solution = extract(state)
          if solution.empty?
            0
          else
            solution.map(&:size).reduce(:+)
          end
        end
      end

      def layers(state)
        fact_layers = {}
        action_layers = {}
        step = 0
        scheduled_facts = state.raw
        scheduled_actions = []
        pre2actions = {}
        @actions.each do |action|
          if action.pre.empty?
            action.difficulty = 0
            scheduled_actions << action
          else
            action.difficulty = Float::INFINITY
            action.counter = 0
            action.pre.each do |lit|
              pre2actions[lit] ||= []
              pre2actions[lit] << action
            end
          end
        end
        goal = @goal.pos
        loop do
          scheduled_facts.each do |lit|
            fact_layers[lit] = step
            if actions = pre2actions[lit]
              actions.delete_if do |action|
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
            action_layers[action.object_id] = step
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
        [fact_layers, action_layers]
      end

      def extract(state)
        fact_layers, action_layers = layers(state)
        marks = Hash.new{|h,k| h[k]=Set.new}
        layer2goals = Hash.new{|h,k| h[k]=Set.new}
        @goal.pos.each do |lit|
          layer = fact_layers[lit]
          return nil if layer.nil?
          layer2goals[layer] << lit
        end
        # m = first layer contains all goals
        m = layer2goals.keys.max
        (1..m).to_a.reverse.map do |i|
          Array(layer2goals[i]).map do |g|
            next if marks[g].include?(i)
            next unless actions = @add2actions[g]
            action = actions.select do |a|
              action_layers[a.object_id] == i - 1
            end.min_by(&:difficulty)
            next if action.nil?
            action.pre.each do |lit|
              if fact_layers[lit] != 0 && !marks[lit].include?(i - 1)
                layer2goals[fact_layers[lit]] << lit
              end
            end
            action.add.each do |lit|
              marks[lit] << i
              marks[lit] << i - 1
            end
            action
          end.compact
        end
      end

      private
      def build(problem)
        @goal = problem[:goal]
        @actions = problem[:actions].map do |action|
          Action.new(action)
        end
        @add2actions = {}
        @actions.each do |action|
          action.add.each do |lit|
            @add2actions[lit] ||= []
            @add2actions[lit] << action
          end
        end
      end
    end
  end
end
