require "rparsec/parser"

module RParsec
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
end
