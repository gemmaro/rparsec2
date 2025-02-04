# frozen_string_literal: true

require "test_helper"
require "rparsec/keywords"

class KeywordTestCase < ParserTestCase
  Insensitive = Keywords.case_insensitive(%w{select from where group by order having}) { |x| x.downcase }
  Sensitive = Keywords.case_sensitive(%w{new delete if else then void int}) { |x| x }
  def verifySensitiveKeyword(code, keyword)
    assertParser(code, keyword, Sensitive.lexer.lexeme.nested(Sensitive.parser(keyword)))
    assertParser(code, keyword, Sensitive.lexer.lexeme.nested(Sensitive.parser(keyword.to_sym)))
  end
  def verifyInsensitiveKeyword(code, keyword)
    assertParser(code, keyword.downcase,
      Insensitive.lexer.lexeme.nested(Insensitive.parser(keyword)))
    assertParser(code, keyword.downcase, Insensitive.lexer.lexeme.nested(Insensitive.parser(keyword.downcase.to_sym)))
  end
  def testCaseSensitiveKeywords
    verifySensitiveKeyword('new int void', 'new')
  end
  def testCaseInsensitiveKeywords
    verifyInsensitiveKeyword('select from where', 'SeleCt')
  end
  def testBasics
    assert(!Insensitive.case_sensitive?)
    assert(Sensitive.case_sensitive?)
    assert_equal(:keyword, Sensitive.keyword_symbol)
  end
end
