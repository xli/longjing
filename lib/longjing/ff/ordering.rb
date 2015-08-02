module Longjing
  module FF
    class Ordering
      def initialize(connectivity_graph)
        @actions = connectivity_graph.actions
        @add2actions = connectivity_graph.add2actions
        @del2actions = connectivity_graph.del2actions
      end

      def da(f)
        if actions = @add2actions[f]
          set = Hash[actions[0].del.map{|l|[l, true]}]
          actions[1..-1].inject(set) do |memo, action|
            n = {}
            action.del.each do |f|
              if memo.include?(f)
                n[f] = true
              end
            end
            n
          end
        else
          {}
        end
      end

      def possibly_achievable_atoms(p, action_set)
        if actions = @add2actions[p]
          actions.any? do |action|
            next unless action_set.include?(action)
            action.pre.all? do |lit|
              if acs = @add2actions[lit]
                acs.any? do |a|
                  action_set.include?(a) && a != action
                end
              end
            end
          end
        end
      end

      def heuristic_fixpoint_reduction(a)
        facts = da(a)
        del_a_actions = @del2actions[a] || {}
        actions = {}
        @actions.each do |action|
          next if del_a_actions.include?(action)
          next if action.pre.any?{|l| facts.include?(l)}
          actions[action] = true
        end

        fixpoint = false
        while(!fixpoint) do
          fixpoint = true
          facts.keys.each do |f|
            if possibly_achievable_atoms(f, actions)
              facts.delete(f)
              actions = {}
              @actions.each do |action|
                next if del_a_actions.include?(action)
                next if action.pre.any?{|l| facts.include?(l)}
                actions[action] = true
              end
              fixpoint = false
            end
          end
        end
        [facts, actions]
      end

      def heuristic_ordering(a, b)
        facts, actions = heuristic_fixpoint_reduction(a)
        possibly_achievable_atoms(b, actions)
      end

      def goal_agenda(prob)
        g = Hash.new{|h,k|h[k]={}}
        list = prob.goal.to_a
        list.each do |a|
          list.each do |b|
            next if a == b
            g[a][b] = !heuristic_ordering(b, a)
          end
        end

        compute_transitive_closure(list, g)

        # in&out edges
        degree = Hash.new{|h,k| h[k]=0}
        hits = Hash.new{|h,k| h[k]=0}
        list.each do |a|
          list.each do |b|
            next if a == b
            if g[a][b]
              degree[a] -= 1
              degree[b] += 1
              hits[a] += 1
              hits[b] += 1
            end
          end
        end

        # order by increasing degree
        # disconnected at the end
        list.sort_by do |a|
          hits[a] == 0 ? Float::INFINITY : degree[a]
        end
      end

      def compute_transitive_closure(nodes, graph)
        nodes.each do |j|
          nodes.each do |i|
            if graph[i][j]
              nodes.each do |k|
                if graph[j][k]
                  graph[i][k] = true
                end
              end
            end
          end
        end
      end
    end
  end
end
