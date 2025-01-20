require "rparsec/parser"

module RParsec
  class SatisfiesParser < Parser # :nodoc:
    init :pred, :expected
    def _parse ctxt
      elem = nil
      if ctxt.eof || !@pred.call(elem = ctxt.current)
        return ctxt.expecting(@expected)
      end
      ctxt.next
      ctxt.retn elem
    end
  end
end
