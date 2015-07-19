require 'longjing/ff/relaxed_graph_plan'

module Longjing
  module FF
    class Search
      def resolve(problem)
        handle_negative_goals(problem)
        state = problem.initial
        h = RelaxedGraphPlan.new(problem)
        best = h.distance(state)
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
          problem.actions(state).each do |action|
            new_state = problem.result(action, state)
            next if known.include?(new_state)
            # ignore infinite heuristic state
            if distance = h.distance(new_state)
              if distance < best
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
    end
  end
end
