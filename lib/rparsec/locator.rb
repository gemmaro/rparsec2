# frozen_string_literal: true

require 'rparsec/misc'

module RParsec

  class CodeLocator # :nodoc:
    extend DefHelper

    def_readable :code

    LF = ?\n

    def locate(ind)
      return _locateEof if ind >= code.length
      line = 1
      col = 1
      return line, col if ind <= 0
      for i in (0...ind)
        c = code[i]
        if c == LF
          line = line + 1
          col = 1
        else
          col = col + 1
        end
      end
      return line, col
    end

    def _locateEof
      line = 1
      col = 1
      code.each_byte do |c|
        if c == LF.ord
          line = line + 1
          col = 1
        else
          col = col + 1
        end
      end
      return line, col
    end
  end

end # module
