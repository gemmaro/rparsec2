# frozen_string_literal: true

require "rparsec/functors"
require "rparsec/monad"
require "rparsec/def_helper"
require "rparsec/parser_monad"
require "rparsec/context"
require "rparsec/error"
require "rparsec/token"
require "rparsec/locator"

module RParsec

  #
  # Represents a parser that parses a certain grammar rule.
  #
  class Parser
    include Functors
    include Monad
    MyMonad = ParserMonad.new
    attr_accessor :name

    class << self
      private

      def init(*vars)
        parser_checker = {}
        vars.each_with_index do |var, i|
          name = var.to_s
          parser_checker[i] = var if name.include?('parser') && !name.include?('parsers')
        end
        define_method(:initialize) do |*params|
          super()
          vars.each_with_index do |var, i|
            instance_variable_set("@#{var}", params[i])
          end
        end
      end
    end

    private

    def initialize
      initMonad(MyMonad, self)
    end

    def _display_current_input(input, _code, _index)
      return 'EOF' if input.nil?
      case (c = input)
      when Integer
        "'" << c << "'"
      when Token
        c.text
      else
        c.to_s
      end
    end

    def _add_encountered_error(msg, encountered)
      result = msg.dup
      result << ', ' unless msg.strip.length == 0 || msg =~ /.*(\.|,)\s*$/
      "#{result}#{encountered}"
    end

    def _add_location_to_error(locator, ctxt, msg, _code)
      line, col = locator.locate(ctxt.error.index)
      msg << " at line #{line}, col #{col}."
    end

    public

    #
    # parses a string.
    #
    def parse(src)
      ctxt = ParseContext.new(src)
      return ctxt.result if _parse ctxt
      ctxt.prepare_error
      locator = CodeLocator.new(src)
      raise ParserException.new(ctxt.error.index),
        _add_location_to_error(locator, ctxt,
          _add_encountered_error(ctxt.to_msg,
             _display_current_input(ctxt.error.input, src, ctxt.index)), src)
    end

    #
    # <tt>a.map { |x| x + 1 }</tt> will first execute parser +a+, when
    # it succeeds, the associated block is executed to transform the
    # result to a new value (increment it in this case).
    #
    def map(&block)
      return self unless block
      MapParser.new(self, block)
    end

    #
    # +self+ is first executed, the parser result is then passed as
    # parameter to the associated +block+, which evaluates to another
    # Parser object at runtime.  This new Parser object is then
    # executed to get the final parser result.
    #
    # Different from #bind, parser result of +self+ will be expanded
    # first if it is an array.
    #
    def bindn(&block)
      return self unless block
      BoundnParser.new(self, block)
    end

    #
    # <tt>a.mapn { |x, y| x + y }</tt> will first execute parser +a+,
    # when it succeeds, the array result (if any) is expanded and
    # passed as parameters to the associated block.  The result of the
    # block is then used as the parsing result.
    #
    def mapn(&block)
      return self unless block
      MapnParser.new(self, block)
    end

    #
    # Create a new parser that's atomic, meaning that when it fails,
    # input consumption is undone.
    #
    def atomize
      AtomParser.new(self).tap { |p| p.name = @name }
    end

    #
    # Create a new parser that looks at inputs whthout consuming them.
    #
    def peek
      PeekParser.new(self).tap { |p| p.name = @name }
    end

    #
    # To create a new parser that succeed only if +self+ fails.
    #
    def not(msg = "#{self} unexpected")
      NotParser.new(self, msg)
    end
    alias ~ not

    #
    # To create a parser that does "look ahead" for _n_ inputs.
    #
    # WARNING: Not implemented yet?
    #
    def lookahead _n # :nodoc:
      self
    end

    #
    # To create a parser that fails with a given error message.
    #
    def expect msg
      ExpectParser.new(self, msg)
    end

    #
    # <tt>a.followed b</tt> will sequentially run +a+ and +b+; result
    # of a is preserved as the ultimate return value.
    #
    def followed(other)
      FollowedParser.new(self, other)
    end
    alias << followed

    #
    # To create a parser that repeats +self+ for a minimum +min+
    # times, and maximally +max+ times.  Only the return value of the
    # last execution is preserved.
    #
    def repeat_(min, max = min)
      return Parsers.failure("min=#{min}, max=#{max}") if min > max
      if min == max
        return Parsers.one if max <= 0
        return self if max == 1
        Repeat_Parser.new(self, max)
      else
        Some_Parser.new(self, min, max)
      end
    end
    alias * repeat_

    #
    # To create a parser that repeats +self+ for a minimum +min+
    # times, and maximally +max+ times.  All return values are
    # collected in an array.
    #
    def repeat(min, max = min)
      return Parsers.failure("min=#{min}, max=#{max}") if min > max
      if min == max
        RepeatParser.new(self, max)
      else
        SomeParser.new(self, min, max)
      end
    end

    #
    # To create a parser that repeats +self+ for at least +least+
    # times.  <tt>parser.many_</tt> is equivalent to bnf notation
    # <tt>parser*</tt>.  Only the return value of the last execution
    # is preserved.
    #
    def many_(least = 0)
      Many_Parser.new(self, least)
    end

    #
    # To create a parser that repeats +self+ for at least +least+
    # times.  All return values are collected in an array.
    #
    def many(least = 0)
      ManyParser.new(self, least)
    end

    #
    # To create a parser that repeats +self+ for at most +max+ times.
    # Only the return value of the last execution is preserved.
    #
    def some_(max)
      repeat_(0, max)
    end

    #
    # To create a parser that repeats +self+ for at most +max+ times.
    # All return values are collected in an array.
    #
    def some(max)
      repeat(0, max)
    end

    #
    # To create a parser that repeats +self+ for unlimited times, with
    # the pattern recognized by +delim+ as separator that separates
    # each occurrence.  +self+ has to match for at least once.  Return
    # values of self are collected in an array.
    #
    def separated1 delim
      rest = delim >> self
      self.bind do |v0|
        result = [v0]
        (rest.map { |v| result << v }).many_ >> value(result)
      end
    end

    #
    # To create a parser that repeats +self+ for unlimited times, with
    # the pattern recognized by +delim+ as separator that separates
    # each occurrence.  Return values of +self+ are collected in an
    # array.
    #
    def separated delim
      separated1(delim).plus value([])
    end

    #
    # To create a parser that repeats +self+ for unlimited times, with
    # the pattern recognized by +delim+ as separator that separates
    # each occurrence and also possibly ends the pattern.  +self+ has
    # to match for at least once.  Return values of +self+ are
    # collected in an array.
    #
    def delimited1 delim
      rest = delim >> (self.plus Parsers.throwp(:__end_delimiter__))
      self.bind do |v0|
        result = [v0]
        (rest.map { |v| result << v }).many_.catchp(:__end_delimiter__) >> value(result)
      end
    end

    #
    # To create a parser that repeats +self+ for unlimited times, with
    # the pattern recognized by +delim+ as separator that separates
    # each occurrence and also possibly ends the pattern.  Return
    # values of +self+ are collected in an array.
    #
    def delimited delim
      delimited1(delim).plus value([])
    end

    #
    # String representation
    #
    def to_s
      return name unless name.nil?
      self.class.to_s
    end

    #
    # <tt>a | b</tt> will run +b+ when +a+ fails.  +b+ is auto-boxed
    # to Parser when it is not of type Parser.
    #
    def | other
      AltParser.new([self, autobox_parser(other)])
    end

    #
    # <tt>a.optional(default)</tt> is equivalent to
    # <tt>a.plus(value(default))</tt>.  See also #plus and #value.
    #
    def optional(default = nil)
      self.plus(value(default))
    end

    #
    # <tt>a.catchp(:somesymbol)</tt> will catch the
    # <tt>:somesymbol</tt> thrown by +a+.
    #
    def catchp(symbol)
      CatchParser.new(symbol, self)
    end

    #
    # <tt>a.fragment</tt> will return the string matched by +a+.
    #
    def fragment
      FragmentParser.new(self)
    end

    #
    # <tt>a.nested b</tt> will feed the token array returned by parser
    # +a+ to parser +b+ for a nested parsing.
    #
    def nested(parser)
      NestedParser.new(self, parser)
    end

    #
    # <tt>a.lexeme(delim)</tt> will parse +a+ for 0 or more times and
    # ignore all patterns recognized by +delim+.  Values returned by
    # +a+ are collected in an array.
    #
    def lexeme(delim = Parsers.whitespaces)
      delim = delim.many_
      delim >> self.delimited(delim)
    end

    #
    # For prefix unary operator.  <tt>a.prefix op</tt> will run parser
    # +op+ for 0 or more times and eventually run parser +a+ for one
    # time.  +op+ should return a +Proc+ that accepts one parameter.
    # +Proc+ objects returned by +op+ is then fed with the value
    # returned by +a+ from right to left.  The final result is
    # returned as return value.
    #
    def prefix(op)
      Parsers.sequence(op.many, self) do |funcs, v|
        funcs.reverse_each { |f| v = f.call(v) }
        v
      end
    end

    #
    # For postfix unary operator.  <tt>a.postfix op</tt> will run
    # parser +a+ for once and then +op+ for 0 or more times.  +op+
    # should return a +Proc+ that accepts one parameter.  +Proc+
    # objects returned by +op+ is then fed with the value returned by
    # +a+ from left to right.  The final result is returned as return
    # value.
    #
    def postfix(op)
      Parsers.sequence(self, op.many) do |v, funcs|
        funcs.each { |f| v = f.call(v) }
        v
      end
    end

    #
    # For non-associative infix binary operator.  +op+ has to return a
    # +Proc+ that takes two parameters, who are returned by the +self+
    # parser as operands.
    #
    def infixn(op)
      bind do |v1|
        bin = Parsers.sequence(op, self) do |f, v2|
          f.call(v1, v2)
        end
        bin | value(v1)
      end
    end

    #
    # For left-associative infix binary operator.  +op+ has to return
    # a +Proc+ that takes two parameters, who are returned by the
    # +self+ parser as operands.
    #
    def infixl(op)
      Parsers.sequence(self, _infix_rest(op, self).many) do |v, rests|
        rests.each do |r|
          f, v1 = *r
          v = f.call(v, v1)
        end
        v
      end
    end

    #
    # For right-associative infix binary operator.  +op+ has to return
    # a +Proc+ that takes two parameters, who are returned by the
    # +self+ parser as operands.
    #
    def infixr(op)
      Parsers.sequence(self, _infix_rest(op, self).many) do |v, rests|
        if rests.empty?
          v
        else
          f, seed = *rests.last
          for i in (0...rests.length - 1)
            cur = rests.length - 2 - i
            f1, v1 = *rests[cur]
            seed = f.call(v1, seed)
            f = f1
          end
          f.call(v, seed)
        end
      end
    end

    #
    # <tt>a.token(:word_token)</tt> will return a Token object when
    # +a+ succeeds.  The matched string (or the string returned by
    # +a+, if any) is encapsulated in the token, together with the
    # <tt>:word_token</tt> symbol and the starting index of the match.
    #
    def token(kind)
      TokenParser.new(kind, self)
    end

    #
    # <tt>a.seq b</tt> will sequentially run +a+ then +b+.  The result
    # of +b+ is preserved as return value.  If a +block+ is
    # associated, values returned by +a+ and +b+ are passed into the
    # +block+ and the return value of the +block+ is used as the final
    # result of the parser.
    #
    def seq(other, &block)
      Parsers.sequence(self, other, &block)
    end

    #
    # Similar to #seq.  +other+ is auto-boxed if it is not of type
    # Parser.
    #
    def >>(other)
      seq(autobox_parser(other))
    end

    private

    def autobox_parser(val)
      return Parsers.value(val) unless val.kind_of? Parser
      val
    end

    def _infix_rest(operator, operand)
      Parsers.sequence(operator, operand, &Idn)
    end

    def _parse(_ctxt)
      false
    end
  end
end
