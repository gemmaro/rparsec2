require "rparsec/parser"

module RParsec
  class AnyParser < Parser # :nodoc:
    def _parse ctxt
      return ctxt.expecting if ctxt.eof
      result = ctxt.current
      ctxt.next
      ctxt.retn result
    end
  end
end
