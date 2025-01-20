require "rparsec/parser"

module RParsec
  class Repeat_Parser < Parser # :nodoc:
    init :parser, :times
    def _parse ctxt
      @times.times do
        return false unless @parser._parse ctxt
      end
      return true
    end
  end
end
