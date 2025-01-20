require "rparsec/parser"

module RParsec
  class Some_Parser < Parser # :nodoc:
    init :parser, :least, :max
    def _parse ctxt
      @least.times { return false unless @parser._parse ctxt }
      (@least...@max).each do
        ind = ctxt.index
        if @parser._parse ctxt
          return true if ind == ctxt.index # infinite loop
          next
        end
        return ind == ctxt.index
      end
      return true
    end
  end
end
