require "rparsec/parser"

module RParsec
  class ThrowParser < Parser # :nodoc:
    init :symbol
    def _parse _ctxt
      throw @symbol
    end
  end
end
