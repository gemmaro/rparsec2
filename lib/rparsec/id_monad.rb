# frozen_string_literal: true

module RParsec

  class IdMonad # :nodoc:
    def value v
      v
    end

    def bind prev
      yield prev
    end

    def mplus a, _b
      a
    end
  end

end # module
