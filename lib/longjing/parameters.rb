require 'set'

module Longjing
  class Parameters
    attr_reader :names

    # params:
    #    typing:     [[name, type], ...]
    #    non-typing: [[name, nil], ...]
    def initialize(params)
      @params = Array(params)
      @names = @params.map {|p| p[0]}
      @types = Set.new(@params.map {|param| param[1]})
    end

    # arguments:
    #    typing:     [[obj, type], ...]
    #    non-typing: [[obj, nil], ...]
    # return: {name => value}
    def permutate(arguments)
      return [{}] if @params.empty?
      type_args = arguments.inject({}) do |memo, arg|
        (memo[arg[1]] ||= []) << arg[0] if @types.include?(arg[1])
        memo
      end
      return [{}] if type_args.size < @types.size

      total = @params.map{|_, t|type_args[t].size}.reduce(:*)
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
  end
end
