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
        Associativities.include?(kind) or raise ArgumentError, "unknown associativity: #{kind}"

        term = ignore_rest(term, delim)
        op = ignore_rest(op, delim)
        term.send(kind, op)
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
