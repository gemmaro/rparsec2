require "rparsec/parser"

module RParsec
  class WatchParser < Parser # :nodoc:
    init :proc
    def _parse ctxt
      @proc.call(ctxt.result)
      true
    end
  end
end
