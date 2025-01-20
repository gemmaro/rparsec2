require "rparsec/parser"

module RParsec
  class Many_Parser < Parser # :nodoc:
    init :parser, :least
    def _parse ctxt
      @least.times do
        return false unless @parser._parse ctxt
      end
      while true
        ind = ctxt.index
        if @parser._parse ctxt
          return true if ind == ctxt.index # infinite loop
          next
        end
        return ind == ctxt.index
      end
    end
  end
end
