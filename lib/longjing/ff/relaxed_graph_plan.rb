module Longjing
  module FF
    class RelaxedGraphPlan
      class Action
        attr_reader :name, :add, :pre, :difficulty
        def initialize(action)
          @pre = action.precond.pos
          @add = action.effect.pos
          @name = Literal.create([:action, action.describe])
          reset
        end

        def count
          @counter -= 1
        end

        def schedule?
          @counter == 0
        end

        def update_difficulty(step)
          @difficulty = step
        end

        def reset
          @difficulty = @pre.empty? ? 0 : nil
          @counter = @pre.size
        end

        def to_s
          "Action[#{@name}]"
        end
      end

      def initialize(problem)
        build(problem.to_h)
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
        layers = {}
        step = 0
        scheduled_facts = state.raw
        scheduled_actions = []
        pre2actions = {}
        @actions.each do |action|
          action.pre.each do |lit|
            pre2actions[lit] ||= []
            pre2actions[lit] << action
          end
          action.reset
          if action.pre.empty?
            scheduled_actions << action
          end
        end
        loop do
          scheduled_facts.each do |lit|
            layers[lit] = step
            if actions = pre2actions[lit]
              actions.delete_if do |action|
                action.count
                if action.schedule?
                  action.update_difficulty(step)
                  scheduled_actions << action
                end
              end
            end
          end
          scheduled_facts = []
          scheduled_actions.each do |action|
            layers[action.name] = step
            action.add.each do |lit|
              unless layers.has_key?(lit)
                scheduled_facts << lit
              end
            end
          end
          scheduled_actions = []
          break if @goal.pos.all? {|lit| layers.has_key?(lit)}
          break if scheduled_facts.empty?
          step += 1
        end
        layers
      end

      def extract(state)
        l = layers(state)
        marks = Hash.new{|h,k| h[k]=Set.new}
        layer2goals = Hash.new{|h,k| h[k]=[]}
        @goal.pos.each do |lit|
          layer = l[lit]
          return nil if layer.nil?
          layer2goals[layer] << lit
        end
        # m = first layer contains all goals
        m = layer2goals.keys.max
        (1..m).to_a.reverse.map do |i|
          Array(layer2goals[i]).map do |g|
            next if marks[g].include?(i)
            next unless actions = @add2actions[g]
            action = actions.select do |action|
              l[action.name] == i - 1
            end.min_by(&:difficulty)
            next if action.nil?
            action.pre.each do |lit|
              l[lit] != 0 && !marks[lit].include?(i - 1)
              layer2goals[l[lit]] << lit
            end
            action.add.each do |lit|
              marks[lit] << i
              marks[lit] << i - 1
            end
            action.name
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
