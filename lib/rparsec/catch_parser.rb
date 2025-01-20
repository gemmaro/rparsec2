require "rparsec/parser"

module RParsec
  class CatchParser < Parser # :nodoc:
    init :symbol, :parser
    def _parse ctxt
      interrupted = true
      ok = false
      catch @symbol do
        ok = @parser._parse(ctxt)
        interrupted = false
      end
      return ctxt.retn(@symbol) if interrupted
      ok
    end
  end
end
