require "rparsec/parser"

module RParsec
  class FollowedParser < Parser # :nodoc:
    init :p1, :p2
    def _parse ctxt
      return false unless @p1._parse ctxt
      result = ctxt.result
      return false unless @p2._parse ctxt
      ctxt.retn(result)
    end
  end
end
