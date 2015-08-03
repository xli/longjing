require 'logger'

module Longjing
  module Logging
    def logger
      @@logger ||= Logger.new(STDOUT).tap {|l| l.level = Logger::WARN}
    end

    def logger=(l)
      @@logger = l
    end

    def log(event=nil, *args, &block)
      case event
      when :exploring
        logger.debug { "\n\nExploring: #{args.join(", ")}\n=======================" }
      when :action
        action, result = args
        logger.debug { "\nAction: #{action.signature}\n-----------------------" }
        logger.debug { "=>  #{result}" }
      when :heuristic
        new_state, solution, dist, best = args
        logger.debug {
          buf = ""
          solution[0].reverse.each_with_index do |a, i|
            buf << "  #{i}. [#{a.map(&:signature).join(", ")}]\n"
          end
          "Relaxed plan (cost: #{dist}):\n#{buf}\n  helpful actions: #{solution[1] ? solution[1].map(&:signature).join(", ") : '[]'}"
        }
        if dist < best
          logger.debug { "Add to plan #{new_state.path.last.signature}, cost: #{dist}" }
        else
          logger.debug { "Add to frontier" }
        end
      when :solution
        logger.info { "\nSolution\n=============" }
        args[0].each_with_index do |step, i|
          logger.info { "#{i}. #{step}" }
        end
      when :problem
        prob = args[0]
        logger.info {
          %{
Problem: #{prob[:problem]}
Domain: #{prob[:domain]}
Requirements: #{prob[:requirements].join(', ')}
Initial: #{prob[:init]}
Goal: #{prob[:goal]}

# types: #{Array(prob[:types]).size}
# predicates: #{prob[:predicates].size}
# actions: #{prob[:actions].size}
# object: #{prob[:objects].size}
}
        }
      when NilClass
        logger.info(&block)
      end
    end
  end
end
