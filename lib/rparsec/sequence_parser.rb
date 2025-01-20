require "rparsec/parser"

module RParsec
  class SequenceParser < Parser # :nodoc:
    init :parsers, :proc
    def _parse ctxt
      if @proc.nil?
        for p in @parsers
          return false unless p._parse(ctxt)
        end
      else
        results = []
        for p in @parsers
          return false unless p._parse(ctxt)
          results << ctxt.result
        end
        ctxt.retn(@proc.call(*results))
      end
      return true
    end
    def seq(other, &block)
      SequenceParser.new(@parsers.dup << other, &block)
    end
  end
end
