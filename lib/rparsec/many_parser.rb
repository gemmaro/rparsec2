require "rparsec/parser"

module RParsec
  class ManyParser < Parser # :nodoc:
    init :parser, :least
    def _parse ctxt
      result = []
      @least.times do
        return false unless @parser._parse ctxt
        result << ctxt.result
      end
      while true
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
    end
  end
end
