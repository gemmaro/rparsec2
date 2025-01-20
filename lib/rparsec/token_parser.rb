require "rparsec/parser"

module RParsec
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
end
