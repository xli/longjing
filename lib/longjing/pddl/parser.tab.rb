#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.12
# from Racc grammer file "".
#

require 'racc/parser.rb'

  require 'strscan'
  require 'longjing/pddl/type'
  require 'longjing/pddl/var'
  require 'longjing/pddl/obj'
  require 'longjing/pddl/predicate'
  require 'longjing/pddl/literal'
  require 'longjing/pddl/action'
module Longjing
  module PDDL
    class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 208)
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
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    37,    38,    37,    38,    16,    33,   140,    34,   117,    39,
   106,    39,    17,    40,    41,    40,    41,    37,    38,   113,
    36,   106,    36,   106,    48,   103,    39,    37,    38,   106,
    40,    41,    26,    27,    28,    50,    39,    36,    27,    28,
    40,    41,    37,    38,    46,    37,    38,    36,    69,    66,
    57,    39,    32,    34,    39,    96,    41,    95,    40,    41,
    37,    38,    36,    59,    60,    36,    28,    25,    70,    39,
    37,    38,    71,    96,    93,    95,    25,   140,    73,    39,
    36,    74,    25,    40,    41,    37,    38,    76,    50,    78,
    36,    22,    81,    32,    39,    37,    38,    83,    40,    41,
    57,    30,    62,    86,    39,    36,    69,    88,    96,    93,
    95,    37,    38,    37,    38,    36,    25,    81,    91,    69,
    39,    22,    39,    97,    40,    41,    40,    41,    37,    38,
    98,    36,   100,    36,    20,     2,   107,    39,    37,    38,
   110,    40,    41,    15,    12,   110,    25,    39,    36,   119,
   120,    40,    41,    37,    38,    37,    38,   122,    36,   106,
    81,   106,    39,   126,    39,   110,    40,    41,    40,    41,
     8,   128,   129,    36,   130,    36,   131,   132,     5,   135,
   138,     4,   141,   142,   138,     3,   145 ]

racc_action_check = [
    95,    95,    94,    94,     8,    15,   120,    15,    97,    95,
   120,    94,     8,    95,    95,    94,    94,    81,    81,    94,
    95,    95,    94,    94,    25,    85,    81,   117,   117,    85,
    81,    81,    12,    12,    12,    26,   117,    81,    20,    20,
   117,   117,   110,   110,    23,    27,    27,   117,    34,    34,
    28,   110,    29,    30,    27,   110,   110,   110,    27,    27,
   138,   138,   110,    31,    32,    27,    22,    21,    35,   138,
    48,    48,    42,   138,   138,   138,    43,   138,    44,    48,
   138,    45,    19,    48,    48,    33,    33,    49,    50,    51,
    48,    18,    53,    14,    33,    69,    69,    55,    33,    33,
    56,    13,    33,    58,    69,    33,    60,    61,    69,    69,
    69,    63,    63,    17,    17,    69,    11,    64,    65,    67,
    63,    10,    17,    71,    63,    63,    17,    17,    57,    57,
    72,    63,    75,    17,     9,     0,    87,    57,    54,    54,
    93,    57,    57,     7,     6,    96,    24,    54,    57,    99,
   100,    54,    54,    52,    52,    16,    16,   102,    54,   104,
   105,   106,    52,   108,    16,   109,    52,    52,    16,    16,
     4,   111,   112,    52,   114,    16,   115,   116,     3,   118,
   119,     2,   133,   134,   135,     1,   139 ]

racc_action_pointer = [
   117,   185,   179,   178,   152,   nil,   126,   125,     1,   116,
   103,    98,    28,    83,    75,    -7,   153,   111,    73,    64,
    33,    49,    60,    25,   128,    17,    15,    43,    32,    34,
    39,    44,    51,    83,    30,    49,   nil,   nil,   nil,   nil,
   nil,   nil,    53,    58,    59,    62,   nil,   nil,    68,    68,
    68,    70,   151,    71,   136,    78,    82,   126,    84,   nil,
    88,    88,   nil,   109,    96,    99,   nil,   101,   nil,    93,
   nil,   105,   111,   nil,   nil,   124,   nil,   nil,   nil,   nil,
   nil,    15,   nil,   nil,   nil,     6,   nil,   117,   nil,   nil,
   nil,   nil,   nil,   122,     0,    -2,   127,     5,   nil,   140,
   132,   nil,   138,   nil,   136,   139,   138,   nil,   144,   147,
    40,   152,   153,   nil,   155,   157,   158,    25,   169,   162,
   -13,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   163,   164,   166,   nil,   nil,    58,   167,
   nil,   nil,   nil,   nil,   nil,   nil ]

racc_action_default = [
   -68,   -68,   -68,   -68,   -68,   146,   -68,   -68,   -68,   -68,
   -68,   -68,   -68,   -68,   -68,   -68,   -68,   -68,   -68,   -68,
   -68,   -68,   -68,   -68,   -18,   -68,   -68,   -68,   -68,   -68,
   -68,   -68,   -68,   -68,   -68,   -68,   -61,   -62,   -63,   -64,
   -65,   -66,   -68,   -68,   -68,   -68,    -4,   -17,   -68,   -68,
   -60,   -68,   -45,   -46,   -55,   -68,   -20,   -68,   -68,    -6,
   -68,   -68,   -13,   -41,   -42,   -68,   -15,   -29,   -30,   -68,
    -7,   -68,   -68,    -2,    -3,   -68,    -9,   -59,   -10,   -44,
   -47,   -68,   -54,   -11,   -19,   -68,    -5,   -68,   -12,   -40,
   -43,   -14,   -28,   -66,   -68,   -68,   -65,   -68,    -1,   -68,
   -68,   -56,   -68,   -49,   -51,   -52,   -58,   -16,   -68,   -33,
   -68,   -68,   -68,   -38,   -68,   -68,   -68,   -68,   -68,   -68,
   -68,   -23,   -48,   -50,   -53,   -57,   -31,   -32,   -34,   -35,
   -36,   -37,   -39,   -68,   -68,   -68,   -24,   -25,   -68,   -68,
   -67,    -8,   -21,   -26,   -27,   -22 ]

racc_goto_table = [
    35,    42,    87,    80,   121,    61,    55,   102,    51,     1,
    65,    53,    23,    49,    90,   109,   112,   115,   116,   134,
    44,    14,    45,   137,   108,    47,   123,    29,    99,   118,
    31,   109,    75,    79,    84,    89,    53,    77,    82,   144,
   127,    85,   139,    92,    72,    58,    11,    13,    10,    19,
    21,    18,     7,    94,     9,   124,     6,   125,    43,   nil,
   nil,   136,   nil,   nil,   nil,   101,   111,   114,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   143,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,    94,   nil,   nil,   nil,   nil,   nil,
   nil,   133,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,    94 ]

racc_goto_check = [
    11,    11,    17,    29,    24,    15,    14,    23,    13,     1,
    16,    28,     6,    12,    29,    25,    23,    23,    25,    22,
     6,     9,     6,    24,    26,     6,    23,     9,    20,    21,
    10,    25,    11,    13,    14,    15,    28,    12,    28,    24,
    26,    11,    23,    16,     6,    10,     5,     8,     4,     5,
     5,     4,     7,    11,     3,    29,     2,    32,     5,   nil,
   nil,    17,   nil,   nil,   nil,    11,    15,    15,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    17,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,    11,   nil,   nil,   nil,   nil,   nil,
   nil,    11,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,    11 ]

racc_goto_pointer = [
   nil,     9,    52,    48,    42,    40,     1,    48,    40,    14,
    16,   -16,   -13,   -19,   -22,   -28,   -24,   -58,   nil,   nil,
   -47,   -70,   -99,   -78,   -96,   -78,   -69,   nil,   -16,   -50,
   nil,   nil,   -49 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    54,   nil,   nil,   nil,   nil,   nil,    67,    24,    56,
   nil,   nil,   nil,   nil,   nil,    68,   nil,    63,    64,   nil,
    52,   104,   105 ]

racc_reduce_table = [
  0, 0, :racc_error,
  8, 25, :_reduce_1,
  7, 25, :_reduce_2,
  7, 25, :_reduce_3,
  6, 25, :_reduce_4,
  7, 25, :_reduce_5,
  6, 25, :_reduce_6,
  4, 26, :_reduce_7,
  8, 31, :_reduce_8,
  4, 27, :_reduce_9,
  4, 28, :_reduce_10,
  4, 29, :_reduce_11,
  4, 32, :_reduce_12,
  3, 32, :_reduce_13,
  4, 33, :_reduce_14,
  3, 33, :_reduce_15,
  4, 34, :_reduce_16,
  2, 30, :_reduce_17,
  1, 30, :_reduce_18,
  2, 38, :_reduce_19,
  1, 38, :_reduce_20,
  7, 42, :_reduce_21,
  4, 44, :_reduce_22,
  2, 44, :_reduce_23,
  2, 45, :_reduce_24,
  2, 45, :_reduce_25,
  2, 46, :_reduce_26,
  2, 46, :_reduce_27,
  2, 40, :_reduce_28,
  1, 40, :_reduce_29,
  1, 41, :_reduce_none,
  4, 41, :_reduce_31,
  2, 50, :_reduce_32,
  1, 50, :_reduce_33,
  4, 49, :_reduce_34,
  4, 49, :_reduce_35,
  4, 49, :_reduce_36,
  4, 49, :_reduce_37,
  3, 49, :_reduce_38,
  4, 49, :_reduce_39,
  2, 39, :_reduce_40,
  1, 39, :_reduce_41,
  1, 39, :_reduce_42,
  2, 51, :_reduce_43,
  2, 37, :_reduce_44,
  1, 37, :_reduce_45,
  1, 37, :_reduce_46,
  2, 54, :_reduce_47,
  4, 43, :_reduce_48,
  3, 43, :_reduce_49,
  2, 47, :_reduce_50,
  1, 47, :_reduce_51,
  1, 47, :_reduce_52,
  2, 55, :_reduce_53,
  2, 52, :_reduce_54,
  1, 52, :_reduce_55,
  2, 53, :_reduce_56,
  2, 56, :_reduce_57,
  1, 56, :_reduce_58,
  2, 36, :_reduce_59,
  1, 36, :_reduce_60,
  1, 35, :_reduce_none,
  1, 35, :_reduce_none,
  1, 35, :_reduce_none,
  1, 35, :_reduce_none,
  1, 35, :_reduce_none,
  1, 35, :_reduce_none,
  2, 48, :_reduce_67 ]

racc_reduce_n = 68

racc_shift_n = 146

racc_token_table = {
  false => 0,
  :error => 1,
  :DEFINE => 2,
  :DOMAIN => 3,
  :REQUIREMENTS => 4,
  :TYPES => 5,
  :PREDICATES => 6,
  :ACTION => 7,
  :PARAMETERS => 8,
  :PRECONDITION => 9,
  :EFFECT => 10,
  :PROBLEM => 11,
  :OBJECTS => 12,
  :GOAL => 13,
  :INIT => 14,
  :NOT => 15,
  :AND => 16,
  :EQUAL => 17,
  :OPEN_BRACE => 18,
  :CLOSE_BRACE => 19,
  :SYMBOL => 20,
  :DASH => 21,
  :ID => 22,
  :VAR => 23 }

racc_nt_base = 24

racc_use_result_var = false

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "DEFINE",
  "DOMAIN",
  "REQUIREMENTS",
  "TYPES",
  "PREDICATES",
  "ACTION",
  "PARAMETERS",
  "PRECONDITION",
  "EFFECT",
  "PROBLEM",
  "OBJECTS",
  "GOAL",
  "INIT",
  "NOT",
  "AND",
  "EQUAL",
  "OPEN_BRACE",
  "CLOSE_BRACE",
  "SYMBOL",
  "DASH",
  "ID",
  "VAR",
  "$start",
  "target",
  "domain_name",
  "requirements",
  "types",
  "predicates",
  "actions",
  "domain_problem",
  "objects",
  "init",
  "goal",
  "name",
  "symbols",
  "type_list",
  "predicate_list",
  "object_list",
  "literals",
  "literal",
  "action",
  "predicate",
  "parameters",
  "precondition",
  "effect",
  "vars_list",
  "empty",
  "atom_literal",
  "atom_literals",
  "objects_t",
  "names",
  "type",
  "types_t",
  "vars_t",
  "var_names" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

module_eval(<<'.,.,', 'parser.y', 14)
  def _reduce_1(val, _values)
     val[2].merge!({
        requirements: val[3],
        types: val[4],
        predicates: val[5],
        actions: val[6]
      })
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 21)
  def _reduce_2(val, _values)
     val[2].merge!({
        requirements: val[3],
        predicates: val[4],
        actions: val[5]
      })
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 27)
  def _reduce_3(val, _values)
     val[2].merge!({
        types: val[3],
        predicates: val[4],
        actions: val[5]
      })
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 33)
  def _reduce_4(val, _values)
     val[2].merge!({
        predicates: val[3],
        actions: val[4]
      })
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 38)
  def _reduce_5(val, _values)
     val[2].merge({ objects: val[3], init: val[4], goal: val[5] })
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 40)
  def _reduce_6(val, _values)
     val[2].merge({ objects: [], init: val[3], goal: val[4] })
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 44)
  def _reduce_7(val, _values)
     domain(val[2]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 49)
  def _reduce_8(val, _values)
     problem(val[2], val[6]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 53)
  def _reduce_9(val, _values)
     requirements(val[2]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 57)
  def _reduce_10(val, _values)
     val[2] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 61)
  def _reduce_11(val, _values)
     val[2] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 65)
  def _reduce_12(val, _values)
     val[2] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 66)
  def _reduce_13(val, _values)
     [] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 70)
  def _reduce_14(val, _values)
     val[2] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 71)
  def _reduce_15(val, _values)
     [] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 75)
  def _reduce_16(val, _values)
     val[2] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 79)
  def _reduce_17(val, _values)
     [val[0]] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 80)
  def _reduce_18(val, _values)
     [val[0]] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 84)
  def _reduce_19(val, _values)
     [val[0]] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 85)
  def _reduce_20(val, _values)
     [val[0]] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 90)
  def _reduce_21(val, _values)
     @params = nil; Action.new(val[2], val[3], val[4], val[5]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 94)
  def _reduce_22(val, _values)
     parameters(val[2]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 95)
  def _reduce_23(val, _values)
     [] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 99)
  def _reduce_24(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 100)
  def _reduce_25(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 104)
  def _reduce_26(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 105)
  def _reduce_27(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 109)
  def _reduce_28(val, _values)
     [val[0]] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 110)
  def _reduce_29(val, _values)
     [val[0]] 
  end
.,.,

# reduce 30 omitted

module_eval(<<'.,.,', 'parser.y', 115)
  def _reduce_31(val, _values)
     And.new(val[2]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 119)
  def _reduce_32(val, _values)
     [val[0]] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 120)
  def _reduce_33(val, _values)
     [val[0]] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 124)
  def _reduce_34(val, _values)
     Fact[@predicates.fetch(val[1]), val[2]] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 125)
  def _reduce_35(val, _values)
     Formula.new(@predicates.fetch(val[1]), val[2]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 126)
  def _reduce_36(val, _values)
     Equal.new(*(val[2])) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 127)
  def _reduce_37(val, _values)
     EqualFormula.new(*(val[2])) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 128)
  def _reduce_38(val, _values)
     Fact[@predicates.fetch(val[1]), []] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 129)
  def _reduce_39(val, _values)
     Not[val[2]] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 133)
  def _reduce_40(val, _values)
     val[0] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 134)
  def _reduce_41(val, _values)
     val[0] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 135)
  def _reduce_42(val, _values)
     val[0].map {|n| object(n)} 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 139)
  def _reduce_43(val, _values)
     val[0].map {|n| object(n, val[1])} 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 143)
  def _reduce_44(val, _values)
     val[0] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 144)
  def _reduce_45(val, _values)
     val[0] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 145)
  def _reduce_46(val, _values)
     val[0].map {|t| type(t)} 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 149)
  def _reduce_47(val, _values)
     val[0].map {|t| type(t, val[1])} 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 153)
  def _reduce_48(val, _values)
     predicate(val[1], val[2]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 154)
  def _reduce_49(val, _values)
     predicate(val[1]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 158)
  def _reduce_50(val, _values)
     val[0] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 159)
  def _reduce_51(val, _values)
     val[0] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 160)
  def _reduce_52(val, _values)
     val[0].map{|v| @params ? @params.fetch(v) : Var.new(v)} 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 164)
  def _reduce_53(val, _values)
     val[0].map{|v| Var.new(v, val[1])} 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 168)
  def _reduce_54(val, _values)
     [val[0]] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 169)
  def _reduce_55(val, _values)
     [val[0]] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 173)
  def _reduce_56(val, _values)
     type(val[1]) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 177)
  def _reduce_57(val, _values)
     [val[0]] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 178)
  def _reduce_58(val, _values)
     [val[0]] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 182)
  def _reduce_59(val, _values)
     [val[0]] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 183)
  def _reduce_60(val, _values)
     [val[0]] 
  end
.,.,

# reduce 61 omitted

# reduce 62 omitted

# reduce 63 omitted

# reduce 64 omitted

# reduce 65 omitted

# reduce 66 omitted

module_eval(<<'.,.,', 'parser.y', 196)
  def _reduce_67(val, _values)
     EMPTY 
  end
.,.,

def _reduce_none(val, _values)
  val[0]
end

    end   # class Parser
    end   # module PDDL
  end   # module Longjing
