# frozen_string_literal: true

require "test_helper"
require "rparsec/operators"

class OperatorTestCase < ParserTestCase
  Ops = Operators.new(%w{++ + - -- * / ~}, &Id)
  def verifyToken(src, op)
    verifyParser(src, op, Ops[op])
  end
  def verifyParser(src, expected, parser)
    assertParser(src, expected, Ops.lexer.lexeme.nested(parser))
  end
  def testAll
    verifyToken('++ -', '++')
    verifyParser('++ + -- ++ - +', '-',
      (Ops['++'] | Ops['--'] | Ops['+']).many_ >> Ops['-'])
  end
  def testSort
    assert_equal(%w{+++ ++- ++ + --- -- -}, Operators.sort(%w{++ - + -- +++ ++- ---}))
  end
end
