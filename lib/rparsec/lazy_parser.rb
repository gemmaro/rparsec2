require "rparsec/parser"

module RParsec
  class LazyParser < Parser # :nodoc:
    init :block
    def _parse ctxt
      @block.call._parse ctxt
    end
  end
end
