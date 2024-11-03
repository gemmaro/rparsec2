# frozen_string_literal: true

require 'rparsec/parser'

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
        is(c, "'#{nm}' expected").setName(nm)
      else
        is(c[0], "'#{c}' expected").setName(c)
      end
    end

    #
    # A parser that succeeds when the the current input is not the given character.
    #
    def not_char(c)
      if c.kind_of? Integer
        nm = c.chr
        isnt(c, "'#{nm}' unexpected").setName("~#{nm}")
      else
        isnt(c[0], "'#{c}' unexpected").setName("~#{c}")
      end
    end

    #
    # A parser that succeeds when there's no input available.
    #
    def eof(expected = "EOF expected")
      EofParser.new(expected).setName('EOF')
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
      are(str, msg).setName(str)
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
      GetIndexParser.new.setName('get_index')
    end

    #
    # A parser that moves the current input pointer to a certain index.
    #
    def set_index ind
      SetIndexParser.new(ind).setName('set_index')
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
      from, to = as_num(from), as_num(to)
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
      RegexpParser.new(as_regexp(ptn), expected).setName(expected)
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
      StringCaseInsensitiveParser.new(str, expected).setName(str)
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

  class FailureParser < Parser # :nodoc:
    init :msg
    def _parse ctxt
      return ctxt.failure(@msg)
    end
  end

  class ValueParser < Parser # :nodoc:
    init :value
    def _parse ctxt
      ctxt.retn @value
    end
  end

  class LazyParser < Parser # :nodoc:
    init :block
    def _parse ctxt
      @block.call._parse ctxt
    end
  end

  class Failures # :nodoc:
    def self.add_error(err, e)
      return e if err.nil?
      return err if e.nil?
      cmp = compare_error(err, e)
      return err if cmp > 0
      return e if cmp < 0
      err
      # merge_error(err, e)
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
        e1, e2 = get_first_element(e1), get_first_element(e2)
        return -1 if e1.index < e2.index
        return 1 if e1.index > e2.index
        0
      end
    end
  end

  ###############################################
  #def merge_error(e1, e2)
  #  return e1 << e2 if e1.kind_of?(Array)
  #  [e1,e2]
  #end
  ###############################################
  class ThrowParser < Parser # :nodoc:
    init :symbol
    def _parse _ctxt
      throw @symbol
    end
  end

  class CatchParser < Parser # :nodoc:
    init :symbol, :parser
    def _parse ctxt
      interrupted = true
      ok = false
      catch @symbol do
        ok = @parser._parse(ctxt)
        interrupted = false
      end
      return ctxt.retn(@symbol) if interrupted
      ok
    end
  end

  class PeekParser < Parser # :nodoc:
    init :parser
    def _parse ctxt
      ind = ctxt.index
      return false unless @parser._parse ctxt
      ctxt.index = ind
      return true
    end
    def peek
      self
    end
  end

  class AtomParser < Parser # :nodoc:
    init :parser
    def _parse ctxt
      ind = ctxt.index
      return true if @parser._parse ctxt
      ctxt.index = ind
      return false
    end
    def atomize
      self
    end
  end

  class LookAheadSensitiveParser < Parser # :nodoc:
    def initialize(la = 1)
      super()
      @lookahead = la
    end
    def visible(ctxt, n)
      ctxt.index - n < @lookahead
    end
    def lookahead(n)
      raise ArgumentError, "lookahead number #{n} should be positive" unless n > 0
      return self if n == @lookahead
      withLookahead(n)
    end
    def not(msg = "#{self} unexpected")
      NotParser.new(self, msg, @lookahead)
    end
  end

  class NotParser < LookAheadSensitiveParser # :nodoc:
    def initialize(parser, msg, la = 1)
      super(la)
      @parser, @msg, @name = parser, msg, "~#{parser.name}"
    end
    def _parse ctxt
      ind = ctxt.index
      if @parser._parse ctxt
        ctxt.index = ind
        return ctxt.expecting(@msg)
      end
      return ctxt.retn(nil) if visible(ctxt, ind)
      return false
    end
    def withLookahead(n)
      NotParser.new(@parser, @msg, n)
    end
    def not()
      @parser
    end
  end

  class ExpectParser < Parser # :nodoc:
    def initialize(parser, msg)
      super()
      @parser, @msg, @name = parser, msg, msg
    end
    def _parse ctxt
      ind = ctxt.index
      return true if @parser._parse ctxt
      return false unless ind == ctxt.index
      ctxt.expecting(@msg)
    end
  end

  class PlusParser < LookAheadSensitiveParser # :nodoc:
    def initialize(alts, la = 1)
      super(la)
      @alts = alts
    end
    def _parse ctxt
      ind, result, err = ctxt.index, ctxt.result, ctxt.error
      for p in @alts
        ctxt.reset_error
        ctxt.index, ctxt.result = ind, result
        return true if p._parse(ctxt)
        return false unless visible(ctxt, ind)
        err = Failures.add_error(err, ctxt.error)
      end
      ctxt.error = err
      return false
    end
    def withLookahead(n)
      PlusParser.new(@alts, n)
    end
    def plus other
      PlusParser.new(@alts.dup << other, @lookahead).setName(name)
    end
  end


  class AltParser < LookAheadSensitiveParser # :nodoc:
    def initialize(alts, la = 1)
      super(la)
      @alts, @lookahead = alts, la
    end
    def _parse ctxt
      ind, result, err = ctxt.index, ctxt.result, ctxt.error
      err_ind, err_pos = -1, -1
      for p in @alts
        ctxt.reset_error
        ctxt.index, ctxt.result = ind, result
        return true if p._parse(ctxt)
        if ctxt.error.index > err_pos
          err, err_ind, err_pos = ctxt.error, ctxt.index, ctxt.error.index
        end
      end
      ctxt.index, ctxt.error = err_ind, err
      return false
    end
    def withLookahead(n)
      AltParser.new(@alts, n)
    end
    def | other
      AltParser.new(@alts.dup << autobox_parser(other)).setName(name)
    end
  end


  class BestParser < Parser # :nodoc:
    init :alts, :longer
    def _parse ctxt
      best_result, best_ind = nil, -1
      err_ind, err_pos = -1, -1
      ind, result, err = ctxt.index, ctxt.result, ctxt.error
      for p in @alts
        ctxt.reset_error
        ctxt.index, ctxt.result = ind, result
        if p._parse(ctxt)
          err, now_ind = nil, ctxt.index
          if best_ind == -1 || (now_ind != best_ind && @longer == (now_ind > best_ind))
            best_result, best_ind = ctxt.result, now_ind
          end
        elsif best_ind < 0 # no good match found yet.
          if ctxt.error.index > err_pos
            err_ind, err_pos = ctxt.index, ctxt.error.index
          end
          err = Failures.add_error(err, ctxt.error)
        end
      end
      if best_ind >= 0
        ctxt.index = best_ind
        return ctxt.retn(best_result)
      else
        ctxt.error, ctxt.index = err, err_ind
        return false
      end
    end
  end

  class BoundParser < Parser # :nodoc:
    init :parser, :proc
    def _parse ctxt
      return false unless @parser._parse(ctxt)
      @proc.call(ctxt.result)._parse ctxt
    end
  end

  class BoundnParser < Parser # :nodoc:
    init :parser, :proc
    def _parse ctxt
      return false unless @parser._parse(ctxt)
      @proc.call(*ctxt.result)._parse ctxt
    end
  end

  class MapParser < Parser # :nodoc:
    init :parser, :proc
    def _parse ctxt
      return false unless @parser._parse(ctxt)
      ctxt.result = @proc.call(ctxt.result)
      true
    end
  end

  class MapnParser < Parser # :nodoc:
    init :parser, :proc
    def _parse ctxt
      return false unless @parser._parse(ctxt)
      ctxt.result = @proc.call(*ctxt.result)
      true
    end
  end

  class SequenceParser < Parser # :nodoc:
    init :parsers, :proc
    def _parse ctxt
      if @proc.nil?
        for p in @parsers
          return false unless p._parse(ctxt)
        end
      else
        results = []
        for p in @parsers
          return false unless p._parse(ctxt)
          results << ctxt.result
        end
        ctxt.retn(@proc.call(*results))
      end
      return true
    end
    def seq(other, &block)
      SequenceParser.new(@parsers.dup << other, &block)
    end
  end

  class FollowedParser < Parser # :nodoc:
    init :p1, :p2
    def _parse ctxt
      return false unless @p1._parse ctxt
      result = ctxt.result
      return false unless @p2._parse ctxt
      ctxt.retn(result)
    end
  end

  class SatisfiesParser < Parser # :nodoc:
    init :pred, :expected
    def _parse ctxt
      elem = nil
      if ctxt.eof || !@pred.call(elem = ctxt.current)
        return ctxt.expecting(@expected)
      end
      ctxt.next
      ctxt.retn elem
    end
  end

  class AnyParser < Parser # :nodoc:
    def _parse ctxt
      return ctxt.expecting if ctxt.eof
      result = ctxt.current
      ctxt.next
      ctxt.retn result
    end
  end

  class EofParser < Parser # :nodoc:
    init :msg
    def _parse ctxt
      return true if ctxt.eof
      return ctxt.expecting(@msg)
    end
  end

  class RegexpParser < Parser # :nodoc:
    init :ptn, :msg
    def _parse ctxt
      scanner = ctxt.scanner
      result = scanner.check @ptn
      if result.nil?
        ctxt.expecting(@msg)
      else
        ctxt.advance(scanner.matched_size)
        ctxt.retn(result)
      end
    end
  end

  class AreParser < Parser # :nodoc:
    init :vals, :msg
    def _parse ctxt
      if @vals.length > ctxt.available
        return ctxt.expecting(@msg)
      end
      cur = 0
      for cur in (0...@vals.length)
        if @vals[cur] != ctxt.peek(cur)
          return ctxt.expecting(@msg)
        end
      end
      ctxt.advance(@vals.length)
      ctxt.retn @vals
    end
  end

  class StringCaseInsensitiveParser < Parser # :nodoc:
    init :str, :msg
    def _downcase c
      case when c.ord >= ?A.ord && c.ord <= ?Z.ord then (c.ord + (?a.ord - ?A.ord)).chr else c end
    end
    private :_downcase

    def _parse ctxt
      if @str.length > ctxt.available
        return ctxt.expecting(@msg)
      end
      cur = 0
      for cur in (0...@str.length)
        if _downcase(@str[cur]) != _downcase(ctxt.peek(cur))
          return ctxt.expecting(@msg)
        end
      end
      result = ctxt.src[ctxt.index, @str.length]
      ctxt.advance(@str.length)
      ctxt.retn result
    end
  end

  class FragmentParser < Parser # :nodoc:
    init :parser
    def _parse ctxt
      ind = ctxt.index
      return false unless @parser._parse ctxt
      ctxt.retn(ctxt.src[ind, ctxt.index - ind])
    end
  end

  class TokenParser < Parser # :nodoc:
    init :symbol, :parser
    def _parse ctxt
      ind = ctxt.index
      return false unless @parser._parse ctxt
      raw = ctxt.result
      raw = ctxt.src[ind, ctxt.index - ind] unless raw.kind_of? String
      ctxt.retn(Token.new(@symbol, raw, ind))
    end
  end

  class NestedParser < Parser # :nodoc:
    init :parser1, :parser2
    def _parse ctxt
      ind = ctxt.index
      return false unless @parser1._parse ctxt
      _run_nested(ind, ctxt, ctxt.result, @parser2)
    end
    private
    def _run_nested(start, ctxt, src, parser)
      ctxt.error = nil
      new_ctxt = nil
      if src.kind_of? String
        new_ctxt = ParseContext.new(src)
        return true if _run_parser parser, ctxt, new_ctxt
        ctxt.index = start + new_ctxt.index
      elsif src.kind_of? Array
        new_ctxt = ParseContext.new(src)
        return true if _run_parser parser, ctxt, new_ctxt
        ctxt.index = start + _get_index(new_ctxt) unless new_ctxt.eof
      else
        new_ctxt = ParseContext.new([src])
        return true if _run_parser parser, ctxt, new_ctxt
        ctxt.index = ind unless new_ctxt.eof
      end
      ctxt.error.index = ctxt.index
      false
    end
    def _get_index ctxt
      cur = ctxt.current
      return cur.index if cur.respond_to? :index
      ctxt.index
    end
    def _run_parser parser, old_ctxt, new_ctxt
      if parser._parse new_ctxt
        old_ctxt.result = new_ctxt.result
        true
      else
        old_ctxt.error = new_ctxt.error
        false
      end
    end
  end

  class WatchParser < Parser # :nodoc:
    init :proc
    def _parse ctxt
      @proc.call(ctxt.result)
      true
    end
  end

  class WatchnParser < Parser
    init :proc
    def _parse ctxt
      @proc.call(*ctxt.result)
      true
    end
  end

  class MapCurrentParser < Parser
    init :proc
    def _parse ctxt
      ctxt.result = @proc.call(ctxt.result)
      true
    end
  end

  class MapnCurrentParser < Parser
    init :proc
    def _parse ctxt
      ctxt.result = @proc.call(*ctxt.result)
      true
    end
  end

  class Repeat_Parser < Parser
    init :parser, :times
    def _parse ctxt
      @times.times do
        return false unless @parser._parse ctxt
      end
      return true
    end
  end

  class RepeatParser < Parser
    init :parser, :times
    def _parse ctxt
      result = []
      @times.times do
        return false unless @parser._parse ctxt
        result << ctxt.result
      end
      return ctxt.retn(result)
    end
  end

  class Many_Parser < Parser
    init :parser, :least
    def _parse ctxt
      @least.times do
        return false unless @parser._parse ctxt
      end
      while true
        ind = ctxt.index
        if @parser._parse ctxt
          return true if ind == ctxt.index # infinite loop
          next
        end
        return ind == ctxt.index
      end
    end
  end

  class ManyParser < Parser
    init :parser, :least
    def _parse ctxt
      result = []
      @least.times do
        return false unless @parser._parse ctxt
        result << ctxt.result
      end
      while true
        ind = ctxt.index
        if @parser._parse ctxt
          result << ctxt.result
          return ctxt.retn(result) if ind == ctxt.index # infinite loop
          next
        end
        if ind == ctxt.index
          return ctxt.retn(result)
        else
          return false
        end
      end
    end
  end

  class Some_Parser < Parser
    init :parser, :least, :max
    def _parse ctxt
      @least.times { return false unless @parser._parse ctxt }
      (@least...@max).each do
        ind = ctxt.index
        if @parser._parse ctxt
          return true if ind == ctxt.index # infinite loop
          next
        end
        return ind == ctxt.index
      end
      return true
    end
  end

  class SomeParser < Parser
    init :parser, :least, :max
    def _parse ctxt
      result = []
      @least.times do
        return false unless @parser._parse ctxt
        result << ctxt.result
      end
      (@least...@max).each do
        ind = ctxt.index
        if @parser._parse ctxt
          result << ctxt.result
          return ctxt.retn(result) if ind == ctxt.index # infinite loop
          next
        end
        if ind == ctxt.index
          return ctxt.retn(result)
        else
          return false
        end
      end
      return ctxt.retn(result)
    end
  end

  class OneParser < Parser
    def _parse _ctxt
      true
    end
  end

  class ZeroParser < Parser
    def _parse ctxt
      return ctxt.failure
    end
  end

  class GetIndexParser < Parser
    def _parse ctxt
      ctxt.retn(ctxt.index)
    end
  end
  class SetIndexParser < Parser
    init :index
    def _parse ctxt
      ctxt.index = @index
    end
  end

  Nil = ValueParser.new(nil)

end # module
