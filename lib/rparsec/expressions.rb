# frozen_string_literal: true

require 'rparsec/parser'

module RParsec

  Associativities = [:prefix, :postfix, :infixn, :infixr, :infixl]
  #
  # This module helps build an expression parser
  # using an OperatorTable instance and a parser
  # that parses the term expression.
  #
  module Expressions
    class << self
      private

      def array_to_dict arr
        result = {}
        arr.each_with_index do |key, i|
          result[key] = i unless result.include? key
        end
        result
      end
    end

    KindPrecedence = array_to_dict Associativities

    #
    # build an expression parser using the given +term+ parser and
    # operator +table+.  When +delim+ is specified, patterns
    # recognized by +delim+ is automatically ignored.
    #
    def self.build(term, table, delim = nil)
      # sort so that higher precedence first.
      apply_operators(term, prepare_suites(table).sort, delim)
    end

    class << self
      private

      def apply_operators(term, entries, delim)
        # apply operators stored in [[precedence,associativity],[op...]] starting from beginning.
        entries.inject(term) do |result, entry|
          key, ops = *entry
          _, kind_index = *key
          op = ops[0]
          op = Parsers.sum(*ops) if ops.length > 1
          apply_operator(result, op, Associativities[kind_index], delim)
        end
      end

      def apply_operator(term, op, kind, delim)
        term, op = ignore_rest(term, delim), ignore_rest(op, delim)
        # we could use send here,
        # but explicit case stmt is more straight forward and less coupled with names.
        # performance might be another benefit,
        # though it is not clear whether meta-code is indeed slower than regular ones at all.
        case kind
        when :prefix
          term.prefix(op)
        when :postfix
          term.postfix(op)
        when :infixl
          term.infixl(op)
        when :infixr
          term.infixr(op)
        when :infixn
          term.infixn(op)
        else
          raise ArgumentError, "unknown associativity: #{kind}"
        end
      end

      def ignore_rest(parser, delim)
        return parser if delim.nil?
        parser << delim
      end

      def prepare_suites(table)
        # create a hash with [precedence, associativity] as key, and op as value.
        suites = {}
        table.operators.each do |entry|
          kind, op, precedence = *entry
          key = [-precedence, KindPrecedence[kind]]
          suite = suites[key]
          if suite.nil?
            suite = [op]
            suites[key] = suite
          else
            suite << op
          end
        end
        suites
      end
    end
  end

end # module
