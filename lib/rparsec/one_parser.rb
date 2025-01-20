require "rparsec/parser"

module RParsec
  class OneParser < Parser # :nodoc:
    def _parse _ctxt
      true
    end
  end
end
