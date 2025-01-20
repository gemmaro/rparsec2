require "rparsec/look_ahead_sensitive_parser"

module RParsec
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
