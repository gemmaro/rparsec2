# frozen_string_literal: true

module RParsec

  class ParserMonad # :nodoc:
    def fail(msg)       = FailureParser.new(msg)
    def value(v)        = v.nil? ? Nil : ValueParser.new(v)
    def bind(v, &block) = block_given? ? BoundParser.new(v, block) : v
    def mplus(p1, p2)   = PlusParser.new([p1, p2])
  end

end # module
