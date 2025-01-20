require "rparsec/parser"
require "rparsec/context"

module RParsec
  class NestedParser < Parser # :nodoc:
    init :parser1, :parser2
    def _parse ctxt
      ind = ctxt.index
      return false unless @parser1._parse ctxt
      _run_nested(ind, ctxt, ctxt.result, @parser2)
    end
    private
    def _run_nested(start, ctxt, src, parser)
      ctxt.error = nil
      new_ctxt = nil
      if src.kind_of? String
        new_ctxt = ParseContext.new(src)
        return true if _run_parser parser, ctxt, new_ctxt
        ctxt.index = start + new_ctxt.index
      elsif src.kind_of? Array
        new_ctxt = ParseContext.new(src)
        return true if _run_parser parser, ctxt, new_ctxt
        ctxt.index = start + _get_index(new_ctxt) unless new_ctxt.eof
      else
        new_ctxt = ParseContext.new([src])
        return true if _run_parser parser, ctxt, new_ctxt
        ctxt.index = ind unless new_ctxt.eof
      end
      ctxt.error.index = ctxt.index
      false
    end
    def _get_index ctxt
      cur = ctxt.current
      return cur.index if cur.respond_to? :index
      ctxt.index
    end
    def _run_parser parser, old_ctxt, new_ctxt
      if parser._parse new_ctxt
        old_ctxt.result = new_ctxt.result
        true
      else
        old_ctxt.error = new_ctxt.error
        false
      end
    end
  end
end
