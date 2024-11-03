# frozen_string_literal: true

%w{
parsers operators keywords expressions
}.each { |lib| require "rparsec/#{lib}" }

module RParsec
  VERSION = "1.1.0"
end
