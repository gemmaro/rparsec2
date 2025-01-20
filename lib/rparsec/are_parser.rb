require "rparsec/parser"

module RParsec
  class AreParser < Parser # :nodoc:
    init :vals, :msg
    def _parse ctxt
      if @vals.length > ctxt.available
        return ctxt.expecting(@msg)
      end
      cur = 0
      for cur in (0...@vals.length)
        if @vals[cur] != ctxt.peek(cur)
          return ctxt.expecting(@msg)
        end
      end
      ctxt.advance(@vals.length)
      ctxt.retn @vals
    end
  end
end
