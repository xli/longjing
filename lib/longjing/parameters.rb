require 'longjing/literal'

module Longjing
  class Parameters
    attr_reader :names

    # params:
    #    typing:     [[name, type], ...]
    #    non-typing: [name, ...]
    # types:
    #    typing:     [[type, parent], ...]
    #    non-typing: nil
    def initialize(params, types=nil)
      @typing = types != nil ? lambda {|o| o} : lambda {|o| [o, nil]}
      @params = Array(params).map(&@typing)
      @names = @params.map {|p| p[0]}
      @obj_types = @params.map {|param| param[1]}.uniq
      @types = flatten(types)
    end

    def propositionalize(action, objects)
      permutate(objects).map do |variables|
        next unless precond = substitute(action[:precond], variables)
        next unless effect = substitute(action[:effect], variables)
        action.merge(:precond => precond,
                     :effect => effect,
                     :describe => lambda { "#{action[:name]}(#{arguments(variables).join(" ")})" })
      end.compact
    end

    # arguments:
    #    typing:     [[obj, type], ...]
    #    non-typing: [obj, ...]
    # return: {name => value}
    def permutate(arguments)
      Longjing.logger.debug { "permutate arguments #{arguments.size} for params #{@params.inspect}" }
      arguments = arguments.map(&@typing)
      return [{}] if @params.empty?
      type_args = {}
      @params.each do |name, type|
        next if type_args.has_key?(type)
        type_args[type] = arguments.select do |obj, arg_type|
          arg_type == type || parent?(type, arg_type)
        end.map{|arg| arg[0]}
      end
      return [{}] if type_args.values.reject(&:empty?).size < @obj_types.size

      Longjing.logger.debug { "type arguments: #{type_args.map { |k,v| [k, v.size].join(':')}.join(', ')}" }

      total = @params.map{|_, t|type_args[t].size}.reduce(:*)
      Longjing.logger.debug { "combinations: #{total}" }
      repeat = total
      ret = Array.new(total) {|i| []}
      @params.each do |param|
        args = type_args[param[1]]
        repeat = repeat / args.size
        loop = ret.size / args.size / repeat
        loop.times do |i|
          args.each_with_index do |arg, j|
            repeat.times do |k|
              ret[i*(args.size*repeat) + j*repeat + k] << arg
            end
          end
        end
      end

      ret.map(&method(:pair))
    end

    def pair(arguments)
      Hash[@names.zip(arguments)]
    end

    def arguments(variables)
      names.map {|n| variables[n]}
    end

    def substitute(literals, variables)
      known = {}
      ret = []
      literals.each do |lit|
        l = Literal.create(lit.map { |atom| variables[atom] || atom })
        if l.exp?
          return nil if !l.match?
        else
          pos = l.positive
          return nil if known.has_key?(pos)
          known[pos] = true
          ret << l
        end
      end
      ret
    end

    private
    def parent?(p, c)
      return false if @types.empty?
      parents = @types[c]
      parents.nil? ? p == nil : parents.include?(p)
    end

    def flatten(types)
      ret = {}
      Array(types).each do |type, parent|
        ret[type] ||= []
        ret[type] << parent
        if ret[parent]
          ret[type].concat(ret[parent])
        end
      end
      ret
    end
  end
end
