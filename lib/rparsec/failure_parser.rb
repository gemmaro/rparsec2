require "rparsec/parser"

module RParsec
  class FailureParser < Parser # :nodoc:
    init :msg
    def _parse ctxt
      return ctxt.failure(@msg)
    end
  end
end
