require "rparsec/look_ahead_sensitive_parser"

module RParsec
  class AltParser < LookAheadSensitiveParser # :nodoc:
    def initialize(alts, la = 1)
      super(la)
      @alts = alts
      @lookahead = la
    end
    def _parse ctxt
      ind = ctxt.index
      result = ctxt.result
      err = ctxt.error
      err_ind = -1
      err_pos = -1
      for p in @alts
        ctxt.reset_error
        ctxt.index = ind
        ctxt.result = result
        return true if p._parse(ctxt)
        if ctxt.error.index > err_pos
          err = ctxt.error
          err_ind = ctxt.index
          err_pos = ctxt.error.index
        end
      end
      ctxt.index = err_ind
      ctxt.error = err
      return false
    end
    def withLookahead(n)
      AltParser.new(@alts, n)
    end
    def | other
      AltParser.new(@alts.dup << autobox_parser(other)).tap { |p| p.name = name }
    end
  end
end
