require 'logger'

module Longjing
  module Logging
    def logger
      @@logger ||= Logger.new(STDOUT).tap do |l|
        l.level = Logger::WARN
        l.formatter = proc do |severity, datetime, progname, msg|
          "#{severity[0]} #{datetime}: #{msg}\n"
        end
      end
    end

    def logger=(l)
      @@logger = l
    end

    def log(event=nil, *args, &block)
      case event
      when :exploring
        state = args[0]
        logger.debug { "\n\nExploring: #{state}\n=======================" }
      when :action
        action, result = args
        logger.debug { "\nAction: #{action.signature}\n-----------------------" }
        logger.debug { "=>  #{result}" }
      when :heuristic
        new_state, solution, best = args
        logger.debug {
          buf = ""
          solution[0].reverse.each_with_index do |a, i|
            buf << "  #{i}. [#{a.map(&:signature).join(", ")}]\n"
          end
          "Relaxed plan (cost: #{new_state.cost}):\n#{buf}\n  helpful actions: #{solution[1] ? solution[1].map(&:signature).join(", ") : '[]'}"
        }
        if new_state.cost < best
          logger.debug { "Add to plan #{new_state.path.last.signature}, cost: #{new_state.cost}" }
        else
          logger.debug { "Add to frontier" }
        end
      when :facts
        args[0].each_slice(3) do |group|
          logger.info { "  #{group.map(&:to_s).join(' ')}"}
        end
      when :problem
        prob = args[0]
        logger.info {
          "Problem: #{prob[:problem]}, domain: #{prob[:domain]}"
        }
        logger.info {
          "Requirements: #{prob[:requirements].join(', ')}"
        }
        log(:problem_stats, prob)
      when :problem_stats
        prob = args[0]
        logger.info { "# types: #{Array(prob[:types]).size}" }
        logger.info { "# predicates: #{prob[:predicates].size}" }
        logger.info { "# object: #{prob[:objects].size}" }
        logger.info { "# actions: #{prob[:actions].size}" }
      when NilClass
        logger.info(&block)
      end
    end
  end
end
