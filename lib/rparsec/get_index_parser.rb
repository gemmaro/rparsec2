require 'rparsec/parser'

module RParsec
  class GetIndexParser < Parser # :nodoc:
    def _parse ctxt
      ctxt.retn(ctxt.index)
    end
  end
end
