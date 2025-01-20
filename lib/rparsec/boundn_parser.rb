require "rparsec/parser"

module RParsec
  class BoundnParser < Parser # :nodoc:
    init :parser, :proc
    def _parse ctxt
      return false unless @parser._parse(ctxt)
      @proc.call(*ctxt.result)._parse ctxt
    end
  end
end
