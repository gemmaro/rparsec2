# character unit version 'strscan'
class StringScanner
  def initialize(s)
    @str = s
    @matched_size = 0
    @pos = 0
  end
  attr_accessor :pos
  attr_reader :matched, :matched_size
  def check(re)
    m = /\G#{re}/.match(@str, @pos)
    if m
      @matched = m[0]
      @matched_size = m[0].size
    else
      @matched_size = 0
      @matched = nil
    end
    @matched
  end
  def scan(re)
    ret = check(re)
    @pos += @matched_size
    ret
  end
end

if $0 == __FILE__
  require 'test/unit'
  class TestStringScanner < Test::Unit::TestCase
    def test_scan
      s = StringScanner.new('test string')
      assert_equal(nil, s.matched)     # => nil
      assert_equal("test", s.scan(/\w+/)) # => "test"
      assert_equal("test", s.matched)     # => "test"
      assert_equal(nil, s.scan(/\w+/)) # => nil
      assert_equal(nil, s.matched)     # => nil
      assert_equal(4, s.pos) # => " "
      assert_equal(" ", s.scan(/\s+/)) # => " "
      assert_equal(" ", s.matched)     # => " "
    end
    def test_check
      s = StringScanner.new('test string')
      assert_equal("test", s.check(/\w+/))
      assert_equal(0, s.pos)
      assert_equal(4, s.matched_size)
      assert_equal("test", s.matched)
      assert_equal(nil, s.check(/\s+/))
      assert_equal(0, s.pos)
      assert_equal(0, s.matched_size)
      assert_equal(nil, s.matched)
    end
  end
end
