require "rparsec/parser"

module RParsec
  class MapCurrentParser < Parser # :nodoc:
    init :proc
    def _parse ctxt
      ctxt.result = @proc.call(ctxt.result)
      true
    end
  end
end
