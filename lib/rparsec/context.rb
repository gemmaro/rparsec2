# frozen_string_literal: true

require 'strscan'

module RParsec

  class ParseContext # :nodoc:
    attr_reader :src
    attr_accessor :error, :index, :result

    def initialize(src, index=0, error=nil)
      @src = src
      @index = index
      @error = error
      @scanner = nil
    end

    def scanner
      @scanner = StringScanner.new(src) if @scanner.nil?
      @scanner.pos = @index
      @scanner
    end

    def prepare_error
      @error.flatten! if @error.kind_of?(Array)
    end

    def to_msg
      return '' if @error.nil?
      return @error.msg unless @error.kind_of?(Array)
      @error.map { |e| e.msg }.join(' or ')
    end

    def error_input
      return nil if @error.nil?
      err = @error
      err = err.last if err.kind_of? Array
      err.input
    end

    def reset_error
      @error = nil
    end

    def current
      @src[@index]
    end

    def eof
      @index >= @src.length
    end

    def available
      @src.length - @index
    end

    def peek i
      @src[@index + i]
    end

    def next
      @index += 1
    end

    def advance n
      @index += n
    end

    def retn(val)
      @result = val
      true
    end

    def failure(msg=nil)
      @error = Failure.new(@index, get_current_input, msg)
      return false
    end

    def expecting(expected=nil)
      @error = Expected.new(@index, get_current_input, expected)
      return false
    end

    def get_current_input
      return nil if eof
      current
    end
  end

end # module
