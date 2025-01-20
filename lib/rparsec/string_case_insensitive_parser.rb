require "rparsec/parser"

module RParsec
  class StringCaseInsensitiveParser < Parser # :nodoc:
    init :str, :msg
    def _downcase c
      case when c.ord >= ?A.ord && c.ord <= ?Z.ord then (c.ord + (?a.ord - ?A.ord)).chr else c end
    end
    private :_downcase

    def _parse ctxt
      if @str.length > ctxt.available
        return ctxt.expecting(@msg)
      end
      cur = 0
      for cur in (0...@str.length)
        if _downcase(@str[cur]) != _downcase(ctxt.peek(cur))
          return ctxt.expecting(@msg)
        end
      end
      result = ctxt.src[ctxt.index, @str.length]
      ctxt.advance(@str.length)
      ctxt.retn result
    end
  end
end
