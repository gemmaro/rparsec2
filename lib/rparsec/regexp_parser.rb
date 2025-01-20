require "rparsec/parser"

module RParsec
  class RegexpParser < Parser # :nodoc:
    init :ptn, :msg
    def _parse ctxt
      scanner = ctxt.scanner
      result = scanner.check @ptn
      if result.nil?
        ctxt.expecting(@msg)
      else
        ctxt.advance(scanner.matched_size)
        ctxt.retn(result)
      end
    end
  end
end
