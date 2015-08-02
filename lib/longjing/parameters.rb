module Longjing
  class Parameters
    def initialize(action)
      @action = action
      @params = action.params
    end

    def propositionalize(objects)
      return [@action] if objects.empty?
      permutate(objects).map do |arguments|
        @action.substitute(arguments)
      end.compact
    end

    # return: [objs, objs...]
    def permutate(arguments)
      Longjing.logger.debug { "permutate arguments #{arguments.size} for params #{@params.inspect}" }
      return [] if @params.empty?
      type_args = {}
      @params.each do |param|
        next if type_args.has_key?(param.type)
        type_args[param.type] = arguments.select do |obj|
          obj.is_a?(param.type)
        end
      end
      return [] if type_args.values.reject(&:empty?).size < @params.map(&:type).uniq.size

      Longjing.logger.debug { "type arguments: #{type_args.map { |k,v| [k, v.size].join(':')}.join(', ')}" }

      total = @params.map{|param|type_args[param.type].size}.reduce(:*)
      Longjing.logger.debug { "combinations: #{total}" }
      repeat = total
      ret = Array.new(total) {|i| []}
      @params.each do |param|
        args = type_args[param.type]
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
      ret
    end
  end
end
