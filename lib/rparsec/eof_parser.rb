require "rparsec/parser"

module RParsec
  class EofParser < Parser # :nodoc:
    init :msg
    def _parse ctxt
      return true if ctxt.eof
      return ctxt.expecting(@msg)
    end
  end
end
