class Longjing::PDDL::Parser
  options no_result_var

  token DEFINE DOMAIN REQUIREMENTS TYPES PREDICATES
        ACTION PARAMETERS PRECONDITION EFFECT
        PROBLEM OBJECTS GOAL INIT
        NOT AND EQUAL
        OPEN_BRACE CLOSE_BRACE
        SYMBOL DASH ID VAR

  rule

  target
  : OPEN_BRACE DEFINE domain_name requirements types predicates actions CLOSE_BRACE
    { val[2].merge!({
        requirements: val[3],
        types: val[4],
        predicates: val[5],
        actions: val[6]
      })}
  | OPEN_BRACE DEFINE domain_name requirements predicates actions CLOSE_BRACE
    { val[2].merge!({
        requirements: val[3],
        predicates: val[4],
        actions: val[5]
      })}
  | OPEN_BRACE DEFINE domain_name types predicates actions CLOSE_BRACE
    { val[2].merge!({
        types: val[3],
        predicates: val[4],
        actions: val[5]
      })}
  | OPEN_BRACE DEFINE domain_name predicates actions CLOSE_BRACE
    { val[2].merge!({
        predicates: val[3],
        actions: val[4]
      })}
  | OPEN_BRACE DEFINE domain_problem objects init goal CLOSE_BRACE
    { val[2].merge({ objects: val[3], init: val[4], goal: val[5] })}
  | OPEN_BRACE DEFINE domain_problem init goal CLOSE_BRACE
    { val[2].merge({ objects: [], init: val[3], goal: val[4] })}
  ;

  domain_name
  : OPEN_BRACE DOMAIN name CLOSE_BRACE                 { domain(val[2]) }
  ;

  domain_problem
  : OPEN_BRACE PROBLEM name CLOSE_BRACE OPEN_BRACE DOMAIN name CLOSE_BRACE
    { problem(val[2], val[6]) }
  ;

  requirements
  : OPEN_BRACE REQUIREMENTS symbols CLOSE_BRACE        { requirements(val[2]) }
  ;

  types
  : OPEN_BRACE TYPES type_list CLOSE_BRACE             { val[2] }
  ;

  predicates
  : OPEN_BRACE PREDICATES predicate_list CLOSE_BRACE   { val[2] }
  ;

  objects
  : OPEN_BRACE OBJECTS object_list CLOSE_BRACE         { val[2] }
  | OPEN_BRACE OBJECTS CLOSE_BRACE                     { [] }
  ;

  init
  : OPEN_BRACE INIT literals CLOSE_BRACE   { val[2] }
  | OPEN_BRACE INIT CLOSE_BRACE            { [] }
  ;

  goal
  : OPEN_BRACE GOAL literal CLOSE_BRACE    { val[2] }
  ;

  actions
  : action actions           { [val[0]] + val[1] }
  | action                   { [val[0]] }
  ;

  predicate_list
  : predicate predicate_list { [val[0]] + val[1] }
  | predicate                { [val[0]] }
  ;

  action
  : OPEN_BRACE ACTION name parameters precondition effect CLOSE_BRACE
    { @params = nil; Action.new(val[2], val[3], val[4], val[5]) }
  ;

  parameters
  : PARAMETERS OPEN_BRACE vars_list CLOSE_BRACE   { parameters(val[2]) }
  | PARAMETERS empty                              { [] }
  ;

  precondition
  : PRECONDITION literal                          { val[1] }
  | PRECONDITION empty                            { val[1] }
  ;

  effect
  : EFFECT literal                                { val[1] }
  | EFFECT empty                                  { val[1] }
  ;

  literals
  : literal literals                              { [val[0]] + val[1] }
  | literal                                       { [val[0]] }
  ;

  literal
  : atom_literal
  | OPEN_BRACE AND atom_literals CLOSE_BRACE      { And.new(val[2]) }
  ;

  atom_literals
  : atom_literal atom_literals                    { [val[0]] + val[1] }
  | atom_literal                                  { [val[0]] }
  ;

  atom_literal
  : OPEN_BRACE name object_list CLOSE_BRACE       { Fact[@predicates.fetch(val[1]), val[2]] }
  | OPEN_BRACE name vars_list CLOSE_BRACE         { Formula.new(@predicates.fetch(val[1]), val[2]) }
  | OPEN_BRACE EQUAL object_list CLOSE_BRACE      { Equal.new(*(val[2])) }
  | OPEN_BRACE EQUAL vars_list CLOSE_BRACE        { EqualFormula.new(*(val[2])) }
  | OPEN_BRACE name CLOSE_BRACE                   { Fact[@predicates.fetch(val[1]), []] }
  | OPEN_BRACE NOT atom_literal CLOSE_BRACE       { Not[val[2]] }
  ;

  object_list
  : objects_t object_list    { val[0] + val[1] }
  | objects_t                { val[0] }
  | names                    { val[0].map {|n| object(n)} }
  ;

  objects_t
  : names type               { val[0].map {|n| object(n, val[1])} }
  ;

  type_list
  : types_t type_list        { val[0] + val[1] }
  | types_t                  { val[0] }
  | names                    { val[0].map {|t| type(t)} }
  ;

  types_t
  : names type               { val[0].map {|t| type(t, val[1])} }
  ;

  predicate
  : OPEN_BRACE name vars_list CLOSE_BRACE         { predicate(val[1], val[2]) }
  | OPEN_BRACE name CLOSE_BRACE                   { predicate(val[1]) }
  ;

  vars_list
  : vars_t vars_list                              { val[0] + val[1] }
  | vars_t                                        { val[0] }
  | var_names                                     { val[0].map{|v| @params ? @params.fetch(v) : Var.new(v)} }
  ;

  vars_t
  : var_names type                                { val[0].map{|v| Var.new(v, val[1])} }
  ;

  names
  : name names               { [val[0]] + val[1] }
  | name                     { [val[0]] }
  ;

  type
  : DASH name                { type(val[1]) }
  ;

  var_names
  : VAR var_names            { [val[0]] + val[1] }
  | VAR                      { [val[0]] }
  ;

  symbols
  : SYMBOL symbols           { [val[0]] + val[1] }
  | SYMBOL                   { [val[0]] }
  ;

  name
  : ID
  | DEFINE
  | DOMAIN
  | PROBLEM
  | NOT
  | AND
  ;

  empty
  : OPEN_BRACE CLOSE_BRACE   { EMPTY }
  ;
---- header ----
  require 'strscan'
  require 'longjing/pddl/type'
  require 'longjing/pddl/var'
  require 'longjing/pddl/obj'
  require 'longjing/pddl/predicate'
  require 'longjing/pddl/literal'
  require 'longjing/pddl/action'
---- inner ----
  SUPPORTED_REQUIREMENTS = [:strips, :typing,
                            :'negative-preconditions',
                            :equality]

  def domain(name)
    @predicates, @types = {}, {}
    @domains[name] = { domain: name }
  end

  def problem(name, domain_name)
    domain = @domains[domain_name]
    raise UnknownDomain unless domain
    @predicates = Hash[domain[:predicates].map{|pred| [pred.name, pred]}]
    @types = if domain[:types]
               Hash[domain[:types].map{|t| [t.name, t]}]
             end
    @objects = {}
    { problem: name }.merge(domain)
  end

  def requirements(reqs)
    unsupported = reqs - SUPPORTED_REQUIREMENTS
    raise UnsupportedRequirements, unsupported unless unsupported.empty?
    reqs
  end

  def predicate(name, vars=nil)
    raise "Duplicated predicate name #{name}" if @predicates.has_key?(name)
    @predicates[name] = Predicate.new(name, vars)
  end

  def type(name, parent=nil)
    @types[name] ||= Type.new(name, parent)
  end

  def object(name, type=nil)
    @objects[name] ||= Obj.new(name, type)
  end

  def parameters(params)
    @params = Hash[params.map{|param| [param.name, param]}]
    params
  end

  def parse(str, domains)
    @domains = domains
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
      when m = scanner.scan(/-\s/)
        @tokens.push [:DASH, m.strip.to_sym]
      when m = scanner.scan(/=\s/)
        @tokens.push [:EQUAL, m.strip.to_sym]
      when m = scanner.scan(/define\b/i)
        @tokens.push [:DEFINE, m.to_sym]
      when m = scanner.scan(/\:?domain\b/i)
        @tokens.push [:DOMAIN, m.to_sym]
      when m = scanner.scan(/problem\b/i)
        @tokens.push [:PROBLEM, m.to_sym]
      when m = scanner.scan(/\:requirements\b/i)
        @tokens.push [:REQUIREMENTS, m]
      when m = scanner.scan(/\:types\b/i)
        @tokens.push [:TYPES, m]
      when m = scanner.scan(/\:predicates\b/i)
        @tokens.push [:PREDICATES, m]
      when m = scanner.scan(/\:action\b/i)
        @tokens.push [:ACTION, m]
      when m = scanner.scan(/\:parameters\b/i)
        @tokens.push [:PARAMETERS, m]
      when m = scanner.scan(/\:precondition\b/i)
        @tokens.push [:PRECONDITION, m]
      when m = scanner.scan(/\:effect\b/i)
        @tokens.push [:EFFECT, m]
      when m = scanner.scan(/\:objects\b/i)
        @tokens.push [:OBJECTS, m]
      when m = scanner.scan(/\:goal\b/i)
        @tokens.push [:GOAL, m]
      when m = scanner.scan(/\:init\b/i)
        @tokens.push [:INIT, m]
      when m = scanner.scan(/not\b/i)
        @tokens.push [:NOT, m.to_sym]
      when m = scanner.scan(/and\b/i)
        @tokens.push [:AND, m.to_sym]
      when m = scanner.scan(/\:[\w\-]+\b/i)
        @tokens.push [:SYMBOL, m[1..-1].to_sym]
      when m = scanner.scan(/\?[a-z][\w\-]*\b/i)
        @tokens.push [:VAR, m.to_sym]
      when m = scanner.scan(/[a-z][\w\-]*\b/i)
        @tokens.push [:ID, m.to_sym]
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

  def on_error(t, val, vstack)
    trace = vstack.each_with_index.map{|l, i| "#{' ' * i}#{l}"}
    raise ParseError,
          "\nparse error on value #{val.inspect}\n#{trace.join("\n")}"
  end