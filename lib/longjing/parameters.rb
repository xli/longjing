module Longjing
  class Parameters
    def initialize(action)
      @action = action
      @params = action.params
    end

    def propositionalize(objects)
      return [@action] if objects.nil? || objects.empty?
      permutate(objects).map do |arguments|
        @action.substitute(arguments)
      end.compact
    end

    # return: [objs, objs...]
    def permutate(objects)
      return [] if @params.empty?
      type_args = @params.map do |param|
        args = objects.select { |obj| obj.is_a?(param.type) }
        return [] if args.empty?
        args
      end
      Longjing.logger.debug {
        "type arguments: #{type_args.map {|v| v.size}.join(', ')}"
      }

      type_args[0].product(*type_args[1..-1]).reject do |array|
        array.uniq.size < @params.size
      end
    end
  end
end
