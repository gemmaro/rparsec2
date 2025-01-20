require "rparsec/parser"

module RParsec
  class ExpectParser < Parser # :nodoc:
    def initialize(parser, msg)
      super()
      @parser = parser
      @msg = msg
      @name = msg
    end
    def _parse ctxt
      ind = ctxt.index
      return true if @parser._parse ctxt
      return false unless ind == ctxt.index
      ctxt.expecting(@msg)
    end
  end
end
