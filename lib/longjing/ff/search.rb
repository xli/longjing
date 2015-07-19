require 'longjing/ff/relaxed_graph_plan'

module Longjing
  module FF
    class Search
      def resolve(problem)
        log { 'handle negative goals' }
        handle_negative_goals(problem)
        log { 'initialize relaxed graph plan' }
        h = RelaxedGraphPlan.new(problem)
        log { "initial:\n  #{problem.initial.raw.to_a.join("\n  ")}" }
        log { "goal:\n  #{problem.to_h[:goal].to_a.map(&:inspect).join("\n  ")}" }
        state = problem.initial
        best = distance(state, h)
        log { "hill climbing starts" }
        until best == 0 do
          state, best = breadth_first(problem, [state], best, h)
          return {} unless state
        end
        return {
          :solution => state.path.map(&:describe),
          :state => state.raw
        }
      end

      def breadth_first(problem, frontier, best, h)
        known = Set.new(frontier)
        until frontier.empty? do
          state = frontier.shift
          log { "\n---\nworking on state: \n  #{state.raw.to_a.join("\n  ")}" }
          problem.actions(state).each do |action|
            log { "action: #{action.describe}" }
            new_state = problem.result(action, state)
            if known.include?(new_state)
              log {"  known status"}
              next
            end
            # ignore infinite heuristic state
            if distance = distance(new_state, h)
              if distance < best
                log { "act: #{action.describe}" }
                return [new_state, distance]
              else
                known << new_state
                frontier << new_state
              end
            end
          end
        end
        return nil
      end

      private
      def distance(state, graph)
        log { "state:\n  #{state.raw.to_a.join("\n  ")}" }
        if solution = graph.extract(state)
          if solution.empty?
            log { "found solution" }
            0
          else
            solution.map(&:size).reduce(:+).tap do |r|
              log { "relaxed plan: #{r}\n  #{solution.map{|a| a.map(&:name).inspect}.join("\n  ")}" }
            end
          end
        end
      end

      def handle_negative_goals(problem)
        problem = problem.to_h
        neg_goal = Hash[problem[:goal].neg.map {|lit| [lit.positive, lit.negative]}]
        problem[:goal].pos.concat(neg_goal.values)
        problem[:goal].neg.clear

        problem[:actions].each do |action|
          [action.precond, action.effect].each do |lits|
            lits.neg.delete_if do |lit|
              if neg = neg_goal[lit]
                lits.pos << neg
              end
            end
            lits.pos.delete_if do |lit|
              if neg = neg_goal[lit]
                lits.neg << neg
              end
            end
          end
        end
      end

      def log(&block)
        if $VERBOSE
          puts yield
        end
      end
    end
  end
end
