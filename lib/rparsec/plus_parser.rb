require "rparsec/look_ahead_sensitive_parser"
require "rparsec/failures"

module RParsec
  class PlusParser < LookAheadSensitiveParser # :nodoc:
    def initialize(alts, la = 1)
      super(la)
      @alts = alts
    end
    def _parse ctxt
      ind = ctxt.index
      result = ctxt.result
      err = ctxt.error
      for p in @alts
        ctxt.reset_error
        ctxt.index = ind
        ctxt.result = result
        return true if p._parse(ctxt)
        return false unless visible(ctxt, ind)
        err = Failures.add_error(err, ctxt.error)
      end
      ctxt.error = err
      return false
    end
    def withLookahead(n)
      PlusParser.new(@alts, n)
    end
    def plus other
      PlusParser.new(@alts.dup << other, @lookahead).tap { |p| p.name = name }
    end
  end
end
