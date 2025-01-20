require "rparsec/parser"

module RParsec
  class RepeatParser < Parser # :nodoc:
    init :parser, :times
    def _parse ctxt
      result = []
      @times.times do
        return false unless @parser._parse ctxt
        result << ctxt.result
      end
      return ctxt.retn(result)
    end
  end
end
