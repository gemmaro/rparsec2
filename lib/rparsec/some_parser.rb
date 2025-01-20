require "rparsec/parser"

module RParsec
  class SomeParser < Parser # :nodoc:
    init :parser, :least, :max
    def _parse ctxt
      result = []
      @least.times do
        return false unless @parser._parse ctxt
        result << ctxt.result
      end
      (@least...@max).each do
        ind = ctxt.index
        if @parser._parse ctxt
          result << ctxt.result
          return ctxt.retn(result) if ind == ctxt.index # infinite loop
          next
        end
        if ind == ctxt.index
          return ctxt.retn(result)
        else
          return false
        end
      end
      return ctxt.retn(result)
    end
  end
end
