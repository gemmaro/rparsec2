require 'rparsec/parser'

module RParsec
  class SetIndexParser < Parser # :nodoc:
    init :index
    def _parse ctxt
      ctxt.index = @index
    end
  end
end
