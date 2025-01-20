require "rparsec/parser"

module RParsec
  class ZeroParser < Parser # :nodoc:
    def _parse ctxt
      return ctxt.failure
    end
  end
end
