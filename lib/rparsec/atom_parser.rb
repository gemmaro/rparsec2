require "rparsec/parser"

module RParsec
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
end
