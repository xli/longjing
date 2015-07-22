require 'longjing/ff/relaxed_graph_plan'

module Longjing
  module FF
    class Search
      def resolve(problem)
        log { 'Handle negative goals' }
        handle_negative_goals(problem)
        log { 'Initialize relaxed graph plan' }
        h = RelaxedGraphPlan.new(problem)
        log { "Initial:\n  #{problem.initial}" }
        log { "Goal:\n  #{problem.to_h[:goal]}" }
        hill_climbing(problem, h)
      end

      def hill_climbing(problem, h)
        state = problem.initial
        best = if relaxed_solution = h.extract(state)
                 distance(relaxed_solution)
               end

        log { "hill climbing starts" }
        log { "initial cost:  #{best}" }

        return {} unless best
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
          log(:exploring, state)
          problem.actions(state).each do |action|
            new_state = problem.result(action, state)
            log(:action, action, new_state)
            if known.include?(new_state)
              log { "Known state" }
              next
            end

            if solution = h.extract(new_state)
              dist = distance(solution)
              log(:heuristic, new_state, solution, dist, best)
              if dist < best
                return [new_state, dist]
              else
                known << new_state
                frontier << new_state
              end
            else
              # ignore infinite heuristic state
              log { "No relaxed solution" }
            end
          end
        end
        return nil
      end

      private
      def distance(solution)
        if solution.empty?
          0
        else
          solution.map(&:size).reduce(:+)
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

      def log(action=nil, *args, &block)
        return unless $VERBOSE
        case action
        when :exploring
          log {"\n\nExploring: #{args[0]}\n======================="}
        when :action
          log {"\nAction: #{args[0].describe}\n-----------------------"}
          log {"=>  #{args[1]}"}
        when :heuristic
          new_state, solution, dist, best = args
          log {
            buf = ""
            solution[0].reverse.each_with_index do |a, i|
              buf << "  #{i}. [#{a.map(&:describe).join(", ")}]\n"
            end
            "Relaxed plan (cost: #{dist}):\n#{buf}"
          }
          if dist < best
            log { "Add to plan #{dist}, #{new_state.path.last.describe}" }
          else
            log { "Add to frontier" }
          end
        when NilClass
          puts yield
        end
      end
    end
  end
end
