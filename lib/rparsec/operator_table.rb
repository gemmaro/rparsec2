module RParsec
  #
  # This class holds information about operator precedences and
  # associativities.  #prefix, #postfix, #infixl, #infixr, #infixn can
  # be called to register operators.
  #
  class OperatorTable

    #
    # Operator attributes.
    #
    attr_reader :operators # :nodoc:

    #
    # Re-initialize the operator table.
    #
    def reinit # :nodoc:
      @operators = []
    end

    #
    # To create an OperatorTable instance.  If a block is given, it is
    # invoked to do post-instantiation.  For example:
    #
    #   OperatorTable.new do |tbl|
    #     tbl.infixl(char(?+) >> Plus, 10)
    #     tbl.infixl(char(?-) >> Minus, 10)
    #     tbl.infixl(char(?*) >> Mul, 20)
    #     tbl.infixl(char(?/) >> Div, 20)
    #     tbl.prefix(char(?-) >> Neg, 50)
    #   end
    #
    def self.new
      this = allocate
      this.reinit
      if block_given?
        yield this
      end
      this
    end

    #
    # Defines a prefix operator that returns a unary +Proc+ object with a precedence associated.
    # Returns +self+.
    #
    def prefix(op, precedence)
      add(:prefix, op, precedence)
    end

    #
    # Defines a postfix operator that returns a unary +Proc+ object with a precedence associated.
    # Returns +self+.
    #
    def postfix(op, precedence)
      add(:postfix, op, precedence)
    end

    #
    # Defines a left associative infix operator that returns a binary +Proc+ object with a precedence
    # associated. Returns +self+.
    #
    def infixl(op, precedence)
      add(:infixl, op, precedence)
    end

    #
    # Defines a right associative infix operator that returns a binary +Proc+ object with a precedence
    # associated. Returns +self+.
    #
    def infixr(op, precedence)
      add(:infixr, op, precedence)
    end

    #
    # Defines a non-associative infix operator that returns a binary +Proc+ object with a precedence
    # associated. Returns +self+.
    #
    def infixn(op, precedence)
      add(:infixn, op, precedence)
    end

    private

    def add(*entry)
      @operators << entry
      self
    end
  end
end
