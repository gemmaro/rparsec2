# frozen_string_literal: true

require 'rparsec/alt_parser'
require 'rparsec/any_parser'
require 'rparsec/are_parser'
require 'rparsec/atom_parser'
require 'rparsec/best_parser'
require 'rparsec/bound_parser'
require 'rparsec/boundn_parser'
require 'rparsec/catch_parser'
require 'rparsec/eof_parser'
require 'rparsec/expect_parser'
require 'rparsec/failure_parser'
require 'rparsec/followed_parser'
require 'rparsec/fragment_parser'
require 'rparsec/get_index_parser'
require 'rparsec/lazy_parser'
require 'rparsec/many__parser'
require 'rparsec/many_parser'
require 'rparsec/map_current_parser'
require 'rparsec/map_parser'
require 'rparsec/mapn_current_parser'
require 'rparsec/mapn_parser'
require 'rparsec/nested_parser'
require 'rparsec/one_parser'
require 'rparsec/peek_parser'
require 'rparsec/plus_parser'
require 'rparsec/regexp_parser'
require 'rparsec/repeat__parser'
require 'rparsec/repeat_parser'
require 'rparsec/satisfies_parser'
require 'rparsec/sequence_parser'
require 'rparsec/set_index_parser'
require 'rparsec/some__parser'
require 'rparsec/some_parser'
require 'rparsec/string_case_insensitive_parser'
require 'rparsec/throw_parser'
require 'rparsec/token_parser'
require 'rparsec/value_parser'
require 'rparsec/watch_parser'
require 'rparsec/watchn_parser'
require 'rparsec/zero_parser'

module RParsec
  #
  # This module provides all out-of-box parser implementations.
  #
  module Parsers
    #
    # A parser that always fails with the given error message.
    #
    def failure msg
      FailureParser.new(msg)
    end

    #
    # A parser that always succeeds with the given return value.
    #
    def value v
      ValueParser.new(v)
    end

    #
    # A parser that calls alternative parsers until one succeed,
    # or any failure with input consumption beyond the current look-ahead.
    #
    def sum(*alts)
      PlusParser.new(alts)
    end

    #
    # A parser that calls alternative parsers until one succeeds.
    #
    def alt(*alts)
      AltParser.new(alts)
    end

    #
    # A parser that succeeds when the given predicate returns true
    # (with the current input as the parameter).  +expected+ is the
    # error message when +pred+ returns false.
    #
    def satisfies(expected, &pred)
      SatisfiesParser.new(pred, expected)
    end

    #
    # A parser that succeeds when the the current input is equal to
    # the given value.  +expected+ is the error message when the
    # predicate returns false.
    #
    def is(v, expected = "#{v} expected")
      satisfies(expected) { |c| c == v }
    end

    #
    # A parser that succeeds when the the current input is not equal
    # to the given value.  +expected+ is the error message when the
    # predicate returns false.
    #
    def isnt(v, expected = "#{v} unexpected")
      satisfies(expected) { |c| c != v }
    end

    #
    # A parser that succeeds when the the current input is among the given values.
    #
    def among(*vals)
      expected = "one of [#{vals.join(', ')}] expected"
      vals = as_list vals
      satisfies(expected) { |c| vals.include? c }
    end

    #
    # A parser that succeeds when the the current input is not among the given values.
    #
    def not_among(*vals)
      expected = "one of [#{vals.join(', ')}] unexpected"
      vals = as_list vals
      satisfies(expected) { |c| !vals.include? c }
    end

    #
    # A parser that succeeds when the the current input is the given character.
    #
    def char(c)
      if c.kind_of? Integer
        nm = c.chr
        is(c, "'#{nm}' expected").tap { |p| p.name = nm }
      else
        is(c[0], "'#{c}' expected").tap { |p| p.name = c }
      end
    end

    #
    # A parser that succeeds when the the current input is not the given character.
    #
    def not_char(c)
      if c.kind_of? Integer
        nm = c.chr
        isnt(c, "'#{nm}' unexpected").tap { |p| p.name = "~#{nm}" }
      else
        isnt(c[0], "'#{c}' unexpected").tap { |p| p.name = "~#{c}" }
      end
    end

    #
    # A parser that succeeds when there's no input available.
    #
    def eof(expected = "EOF expected")
      EofParser.new(expected).tap { |p| p.name = "EOF" }
    end

    #
    # A parser that tries to match the current inputs one by one
    # with the given values.
    # It succeeds only when all given values are matched, in which case all the
    # matched inputs are consumed.
    #
    def are(vals, expected = "#{vals} expected")
      AreParser.new(vals, expected)
    end

    #
    # A parser that makes sure that the given values don't match
    # the current inputs. One input is consumed if it succeeds.
    #
    def arent(vals, expected = "#{vals} unexpected")
      are(vals, '').not(expected) >> any
    end

    #
    # A parser that matches the given string.
    #
    def string(str, msg = "\"#{str}\" expected")
      are(str, msg).tap { |p| p.name = str }
    end

    #
    # A parser that makes sure that the current input doesn't match a string.
    # One character is consumed if it succeeds.
    #
    def not_string(str, msg = "\"#{str}\" unexpected")
      string(str).not(msg) >> any
    end

    alias str string

    #
    # A parser that sequentially run the given +parsers+.  The result
    # of the last parser is used as return value.  If a block is
    # given, the results of the +parsers+ are passed into the block as
    # parameters, and the block return value is used as result
    # instead.
    #
    def sequence(*parsers, &proc)
      SequenceParser.new(parsers, proc)
    end

    #
    # A parser that returns the current input index (starting from 0).
    #
    def get_index
      GetIndexParser.new.tap { |p| p.name = 'get_index' }
    end

    #
    # A parser that moves the current input pointer to a certain index.
    #
    def set_index ind
      SetIndexParser.new(ind).tap { |p| p.name = "set_index" }
    end

    #
    # A parser that tries all given alternative +parsers+ and picks
    # the one with the longest match.
    #
    def longest(*parsers)
      BestParser.new(parsers, true)
    end

    #
    # A parser that tries all given alternative +parsers+ and picks
    # the one with the shortest match.
    #
    def shortest(*parsers)
      BestParser.new(parsers, false)
    end

    alias shorter shortest
    alias longer longest

    #
    # A parser that consumes one input.
    #
    def any
      AnyParser.new
    end

    #
    # A parser that always fails.
    #
    def zero
      ZeroParser.new
    end

    #
    # A parser that always succeeds.
    #
    def one
      OneParser.new
    end

    #
    # A parser that succeeds if the current input is within a certain range.
    #
    def range(from, to, msg = "#{as_char from}..#{as_char to} expected")
      from = as_num(from)
      to = as_num(to)
      satisfies(msg) { |c| c <= to && c >= from }
    end

    #
    # A parser that throws a +symbol+.
    #
    def throwp(symbol)
      ThrowParser.new(symbol)
    end

    #
    # A parser that succeeds if the current inputs match
    # the given regular expression.
    # The matched string is consumed and returned as result.
    #
    def regexp(ptn, expected = "/#{ptn}/ expected")
      RegexpParser.new(as_regexp(ptn), expected).tap { |p| p.name = expected }
    end

    #
    # A parser that parses a word
    # (starting with alpha or underscore, followed by 0 or more alpha, number or underscore).
    # and return the matched word as string.
    #
    def word(expected = 'word expected')
      regexp(/[a-zA-Z_]\w*/, expected)
    end

    #
    # A parser that parses an integer
    # and return the matched integer as string.
    #
    def integer(expected = 'integer expected')
      regexp(/\d+(?!\w)/, expected)
    end

    #
    # A parser that parses a number (integer, or decimal number)
    # and return the matched number as string.
    #
    def number(expected = 'number expected')
      regexp(/\d+(\.\d+)?/, expected)
    end

    #
    # A parser that matches the given string, case insensitively.
    #
    def string_nocase(str, expected = "'#{str}' expected")
      StringCaseInsensitiveParser.new(str, expected).tap { |p| p.name = str }
    end

    #
    # A parser that succeeds when the current input is a token with
    # one of the the given token +kinds+.  If a block is given, the
    # token text is passed to the block as parameter, and the block
    # return value is used as result.  Otherwise, the token object is
    # used as result.
    #
    def token(*kinds, &proc)
      expected = "#{kinds.join(' or ')} expected"
      recognizer = nil
      if kinds.length == 1
        kind = kinds[0]
        recognizer = satisfies(expected) do |tok|
          tok.respond_to? :kind, :text and kind == tok.kind
        end
      else
        recognizer = satisfies(expected) do |tok|
          tok.respond_to? :kind, :text and kinds.include? tok.kind
        end
      end
      recognizer = recognizer.map { |tok| proc.call(tok.text) } if proc
      recognizer
    end

    #
    # A parser that parses a white space character.
    #
    def whitespace(expected = "whitespace expected")
      satisfies(expected) { |c| Whitespaces.include? c }
    end

    #
    # A parser that parses 1 or more white space characters.
    #
    def whitespaces(expected = "whitespace(s) expected")
      whitespace(expected).many_(1)
    end

    #
    # A parser that parses a line started with +start+.  +nil+ is the
    # result.
    #
    def comment_line start
      string(start) >> not_char(?\n).many_ >> char(?\n).optional >> value(nil)
    end

    #
    # A parser that parses a chunk of text started with +open+ and
    # ended by +close+.  +nil+ is the result.
    #
    def comment_block open, close
      string(open) >> not_string(close).many_ >> string(close) >> value(nil)
    end

    #
    # A lazy parser, when executed, calls the given +block+ to get a
    # parser object and delegate the call to this lazily instantiated
    # parser.
    #
    def lazy(&block)
      LazyParser.new(block)
    end

    #
    # A parser that watches the current parser result without changing
    # it.  The following assert will succeed:
    ##
    #   char(?a) >> watch { |x| assert_equal(?a, x) }
    #
    # +watch+ can also be used as a handy tool to print trace
    # information, for example:
    #
    #   some_parser >> watch { puts "some_parser succeeded." }
    #
    def watch(&block)
      return one unless block
      WatchParser.new(block)
    end

    #
    # A parser that watches the current parser result without changing
    # it.  The following assert will succeed:
    #
    #   char(?a).repeat(2) >> watchn { |x, y| assert_equal([?a, ?a], [x, y]) }
    #
    # Slightly different from #watch, +watchn+ expands the current
    # parser result before passing it into the associated block.
    #
    def watchn(&block)
      return one unless block
      WatchnParser.new(block)
    end

    #
    # A parser that maps current parser result to a new result using
    # the given +block+.
    #
    # Different from Parser#map, this method does not need to be
    # combined with any Parser object.  It is rather an independent
    # Parser object that maps the _current_ parser result.
    #
    # <tt>parser1.map { |x| ... }</tt> is equivalent to <tt>parser1 >>
    # map { |x| ... }</tt>.
    #
    # See also Parser#>>.
    #
    def map(&block)
      return one unless block
      MapCurrentParser.new(block)
    end

    #
    # A parser that maps current parser result to a new result using
    # the given +block+.  If the current parser result is an array,
    # the array elements are expanded and then passed as parameters to
    # the +block+.
    #
    # Different from Parser#mapn, this method does not need to be
    # combined with any Parser object.  It is rather an independent
    # Parser object that maps the _current_ parser result.
    #
    # <tt>parser1.mapn { |x, y| ... }</tt> is equivalent to
    # <tt>parser1 >> mapn { |x, y| ... }</tt>.
    #
    # See also Parser#>>.
    #
    def mapn(&block)
      return one unless block
      MapnCurrentParser.new(block)
    end

    private

    #
    # characters considered white space.
    #
    Whitespaces = " \t\r\n"

    def as_regexp ptn
      case ptn when String then Regexp.new(ptn) else ptn end
    end

    def as_char c
      case c when String then c else c.chr end
    end

    def as_num c
      case c when String then c[0] else c end
    end

    def as_list vals
      return vals unless vals.length == 1
      val = vals[0]
      return vals unless val.kind_of? String
      val
    end

    extend self
  end

  class Failures # :nodoc:
    def self.add_error(err, e)
      return e if err.nil?
      return err if e.nil?
      cmp = compare_error(err, e)
      return err if cmp > 0
      return e if cmp < 0
      err
    end

    class << self
      private

      def get_first_element(err)
        while err.kind_of?(Array)
          err = err[0]
        end
        err
      end

      def compare_error(e1, e2)
        e1 = get_first_element(e1)
        e2 = get_first_element(e2)
        return -1 if e1.index < e2.index
        return 1 if e1.index > e2.index
        0
      end
    end
  end

  Nil = ValueParser.new(nil) # :nodoc:

end # module
