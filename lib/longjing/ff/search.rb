require 'longjing/ff/greedy_state'
require 'longjing/ff/connectivity_graph'
require 'longjing/ff/relaxed_graph_plan'
require 'longjing/ff/ordering'

module Longjing
  module FF
    class Search
      def resolve(problem)
        log { 'Handle negative goals' }
        handle_negative_goals(problem)
        log { 'Generate connectivity graph' }
        cg = ConnectivityGraph.new(problem)
        log { 'Initialize relaxed graph plan' }
        h = RelaxedGraphPlan.new(cg)
        log { "Initial:\n  #{problem.initial}" }
        log { "Goal:\n  #{problem.to_h[:goal]}" }
        hill_climbing(problem, h, cg) || greedy_search(problem, h)
      end

      def hill_climbing(problem, h, cg)
        log { "hill climbing starts" }
        o = Ordering.new(cg)
        state = problem.initial
        agenda = o.goal_agenda(problem)
        problem.goal.pos.clear
        agenda.each do |g|
          problem.goal.pos << g

          best = if relaxed_solution = h.extract(problem.goal.pos, state)
                   distance(relaxed_solution)
                 end

          log { "initial cost:  #{best}" }

          return unless best
          helpful_actions = relaxed_solution[1]

          until best == 0 do
            state, best, helpful_actions = breadth_first(problem, [state],
                                                         best, h,
                                                         helpful_actions)
            return unless state
          end
        end

        final_solution(state)
      end

      def breadth_first(problem, frontier, best, h, helpful_actions)
        known = Set.new(frontier)
        pos_goals = Set.new(problem.goal.pos)
        until frontier.empty? do
          state = frontier.shift
          log(:exploring, state)
          actions = helpful_actions || problem.actions(state)
          helpful_actions = nil
          actions.each do |action|
            new_state = problem.result(action, state)
            log(:action, action, new_state)
            if known.include?(new_state)
              log { "Known state" }
              next
            end

            added_goals = Set.new(action.effect.pos.select {|lit| pos_goals.include?(lit)})
            if solution = h.extract(problem.goal.pos, new_state, added_goals)
              dist = distance(solution)
              log(:heuristic, new_state, solution, dist, best)
              if dist < best
                return [new_state, dist, solution[1]]
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

      def greedy_search(problem, h)
        initial = problem.initial
        dist = if relaxed_solution = h.extract(problem.goal.pos, initial)
                 distance(relaxed_solution)
               else
                 Float::INFINITY
               end
        log { "greedy search starts" }
        log { "initial cost:  #{dist}" }
        if problem.goal?(initial)
          return final_solution(initial)
        end
        frontier = SortedSet.new([GreedyState.new(initial, dist)])
        known = Set.new([initial])
        until frontier.empty? do
          gs = frontier.first
          frontier.delete(gs)
          state = gs.state
          log(:exploring, state, gs.dist)
          problem.actions(state).each do |action|
            new_state = problem.result(action, state)
            log(:action, action, new_state)
            if known.include?(new_state)
              log { "Known state" }
              next
            end
            if problem.goal?(new_state)
              return final_solution(new_state)
            end
            state_dist = if relaxed_solution = h.extract(problem.goal.pos, new_state)
                           distance(relaxed_solution)
                         else
                           Float::INFINITY
                         end
            known << new_state
            frontier << GreedyState.new(new_state, state_dist)
          end
        end
        return {}
      end

      private
      def final_solution(state)
        {
          :solution => state.path.map(&:describe),
          :state => state.raw
        }
      end

      def distance(solution)
        if solution[0].empty?
          0
        else
          solution[0].map(&:size).reduce(:+)
        end
      end

      def handle_negative_goals(problem)
        neg_goal = Hash[problem.goal.neg.map {|lit| [lit.positive, lit.negative]}]
        problem.goal.pos.concat(neg_goal.values)
        problem.goal.neg.clear

        problem.ground_actions.each do |action|
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
          log {"\n\nExploring: #{args.join(", ")}\n======================="}
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
            "Relaxed plan (cost: #{dist}):\n#{buf}\n  helpful actions: #{solution[1] ? solution[1].map(&:describe).join(", ") : '[]'}"
          }
          if dist < best
            log { "Add to plan #{new_state.path.last.describe}, cost: #{best}" }
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
