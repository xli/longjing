class Longjing::PDDL
  options no_result_var

  token ID OP NUMBER OPEN_BRACE CLOSE_BRACE

  rule
  target: list { val[0] }

  list
     : OPEN_BRACE ids CLOSE_BRACE      { val[1] }
     ;

  ids
     : id ids                          { [val[0]] + val[1] }
     | id                              { [val[0]] }
     ;

  id
     : ID
     | OP
     | NUMBER
     | list
     ;

---- header ----
  require 'strscan'
---- inner ----

  def parse(str)
    @tokens = []
    str = "" if str.nil?
    scanner = StringScanner.new(str + ' ')

    until scanner.eos?
      case
      when scanner.scan(/\s+/)
      # ignore space
      when scanner.scan(/;.*$/)
      # ignore comments
      when m = scanner.scan(/[\(]/)
        @tokens.push [:OPEN_BRACE, m]
      when m = scanner.scan(/[\)]/)
        @tokens.push [:CLOSE_BRACE, m]
      when m = scanner.scan(/(>=|<=)\s/)
        @tokens.push [:OP, m.strip.to_sym]
      when m = scanner.scan(/[-\/*+><=]\s/)
        @tokens.push [:OP, m.strip.to_sym]
      when m = scanner.scan(/(\d+(\.\d+)?)\b/)
        @tokens.push [:NUMBER, m.to_f]
      when m = scanner.scan(/:([\w\-]*)\b/i)
        @tokens.push [:ID, m[1..-1].to_sym]
      when m = scanner.scan(/([a-z?][\w\-]*)\b/i)
        @tokens.push [:ID, m]
      else
        raise "unexpected characters: #{scanner.peek(5).inspect}"
      end
    end
    @tokens.push [false, false]
    do_parse
  end

  def next_token
    @tokens.shift
  end
