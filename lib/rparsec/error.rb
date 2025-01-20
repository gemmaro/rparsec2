# frozen_string_literal: true

require 'rparsec/misc'

module RParsec

  class ParserException < StandardError # :nodoc:
    extend DefHelper
    def_readable :index
  end

  class Failure # :nodoc:
    def initialize(ind, input, message = nil)
      @index = ind
      @input = input
      @msg = message
    end

    attr_reader :index, :input
    attr_writer :index

    def msg = @msg.to_s
  end

  Expected = Class.new(Failure) # :nodoc:

end # module
