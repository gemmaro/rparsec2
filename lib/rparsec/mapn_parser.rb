require "rparsec/parser"

module RParsec
  class MapnParser < Parser # :nodoc:
    init :parser, :proc
    def _parse ctxt
      return false unless @parser._parse(ctxt)
      ctxt.result = @proc.call(*ctxt.result)
      true
    end
  end
end
