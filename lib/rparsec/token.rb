# frozen_string_literal: true

module RParsec

  #
  # Represents a token during lexical analysis.
  #
  # kind  :: The type of the token
  # text  :: The text of the matched range
  # index :: The starting index of the matched range
  #
  Token = Data.define(:kind, :text, :index)

  class Token
    #
    # The length of the token.
    #
    def length = @text.length

    #
    # String representation of the token.
    #
    def to_s = "#{@kind}: #{@text}"
  end

end # module
