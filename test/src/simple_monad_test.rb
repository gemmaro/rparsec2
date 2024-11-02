require_relative 'import'
require 'test/unit'
import :id_monad, :monad

include RParsec
class Idm
  include Monad
  MyMonad = IdMonad.new
  def initialize(v)
    initMonad(MyMonad, v);
  end
  def to_s
    @obj.to_s
  end
end

class SimpleMonadTest < Test::Unit::TestCase
  def test1
    assert_equal 20, Idm.new(10).map{|i|i*2}
    assert_equal 10, Idm.new(10).plus(Idm.new(20))
  end
end
