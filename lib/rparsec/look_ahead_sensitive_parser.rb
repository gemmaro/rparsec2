require "rparsec/parser"

module RParsec
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

  # Define here to avoid circular loadings.
  class NotParser < LookAheadSensitiveParser # :nodoc:
    def initialize(parser, msg, la = 1)
      super(la)
      @parser = parser
      @msg = msg
      @name = "~#{parser.name}"
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
end
