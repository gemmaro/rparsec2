module RParsec
  #
  # This class holds information about operator precedences and
  # associativities.  +prefix+, +postfix+, +infixl+, +infixr+, +infixn+ can be
  # called to register operators.
  #
  # +prefix+ :: Defines a prefix operator that returns a unary +Proc+ object
  #             with a precedence associated.  Returns +self+.
  #
  # +postfix+ :: Defines a postfix operator that returns a unary +Proc+ object
  #              with a precedence associated.  Returns +self+.
  #
  # +infixl+ :: Defines a left associative infix operator that returns a
  #             binary +Proc+ object with a precedence associated. Returns
  #             +self+.
  #
  # +infixr+ :: Defines a right associative infix operator that returns a
  #             binary +Proc+ object with a precedence associated. Returns
  #             +self+.
  #
  # +infixn+ :: Defines a non-associative infix operator that returns a binary
  #             +Proc+ object with a precedence associated. Returns +self+.
  #
  class OperatorTable

    #
    # Operator attributes.
    #
    attr_reader :operators # :nodoc:

    #
    # To create an OperatorTable instance.  If a block is given, it is invoked
    # to do post-instantiation.  For example:
    #
    #   OperatorTable.new do |tbl|
    #     tbl.infixl(char(?+) >> Plus, 10)
    #     tbl.infixl(char(?-) >> Minus, 10)
    #     tbl.infixl(char(?*) >> Mul, 20)
    #     tbl.infixl(char(?/) >> Div, 20)
    #     tbl.prefix(char(?-) >> Neg, 50)
    #   end
    #
    def initialize
      @operators = []
      block_given? and yield self
    end

    %i[prefix postfix infixl infixr infixn].each do |method|
      define_method(method) do |op, precedence|
        @operators << [method, op, precedence]
        self
      end
    end
  end
end
