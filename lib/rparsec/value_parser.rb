require "rparsec/parser"

module RParsec
  class ValueParser < Parser # :nodoc:
    init :value
    def _parse ctxt
      ctxt.retn @value
    end
  end
end
