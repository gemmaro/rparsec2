require "rparsec/parser"

module RParsec
  class FragmentParser < Parser # :nodoc:
    init :parser
    def _parse ctxt
      ind = ctxt.index
      return false unless @parser._parse ctxt
      ctxt.retn(ctxt.src[ind, ctxt.index - ind])
    end
  end
end
