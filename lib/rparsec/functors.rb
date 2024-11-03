# frozen_string_literal: true

module RParsec

  #
  # This module provides frequently used functors.
  #
  module Functors
    Id = proc { |x| x }
    Idn = proc { |*x| x }
    Neg = proc { |x| -x }
    Inc = proc { |x| x + 1 }
    Succ = proc { |x| x.succ }
    Dec = proc { |x| x - 1 }
    Plus = proc { |x, y| x + y }
    Minus = proc { |x, y| x - y }
    Mul = proc { |x, y| x * y }
    Div = proc { |x, y| x / y }
    Mod = proc { |x, y| x % y }
    Power = proc { |x, y| x**y }
    Not = proc { |x, _y| !x }
    And = proc { |x, y| x && y }
    Or = proc { |x, y| x || y }
    Xor = proc { |x, y| x ^ y }
    BitAnd = proc { |x, y| x & y }
    Union = proc { |x, y| x | y }
    Match = proc { |x, y| x =~ y }
    Eq = proc { |x, y| x == y }
    Ne = proc { |x, y| x != y }
    Lt = proc { |x, y| x < y }
    Gt = proc { |x, y| x > y }
    Le = proc { |x, y| x <= y }
    Ge = proc { |x, y| x >= y }
    Compare = proc { |x, y| x <=> y }
    Call = proc { |x, y| x.call(y) }
    Feed = proc { |x, y| y.call(x) }
    Fst = proc { |x, _| x }
    Snd = proc { |_, x| x }
    At = proc { |x, y| x[y] }
    To_a = proc { |x| x.to_a }
    To_s = proc { |x| x.to_s }
    To_i = proc { |x| x.to_i }
    To_sym = proc { |x| x.to_sym }
    To_f = proc { |x| x.to_f }

    #
    # Get a +Proc+, when called, always return the given value.
    #
    def const(v)
      proc { |_| v }
    end

    #
    # Get a +Proc+, when called, return the <tt>n</tt>th parameter.
    #
    def nth(n)
      proc { |*args| args[n] }
    end

    #
    # Create a +Proc+, which expects the two parameters in the reverse
    # order of +block+.
    #
    def flip(&block)
      proc { |x, y| block.call(y, x) }
    end

    #
    # Create a +Proc+, when called, the parameter is first passed into
    # +f2+, +f1+ is called in turn with the return value from +f2+.
    #
    def compose(f1, f2)
      proc { |*x| f1.call(f2.call(*x)) }
    end

    #
    # Create a Proc that's curriable.
    # When curried, parameters are passed in from left to right.
    # i.e. curry(closure).call(a).call(b) is quivalent to closure.call(a,b) .
    # _block_ is encapsulated under the hood to perform the actual
    # job when currying is done.
    # arity explicitly specifies the number of parameters to curry.
    #
    def curry(arity, &block)
      fail "cannot curry for unknown arity" if arity < 0
      Functors.make_curry(arity, &block)
    end

    #
    # Create a +Proc+ that's curriable.  When curried, parameters are
    # passed in from right to left.
    # i.e. <tt>reverse_curry(closure).call(a).call(b)</tt> is
    # quivalent to <tt>closure.call(b, a)</tt>.  +block+ is
    # encapsulated under the hood to perform the actual job when
    # currying is done.  +arity+ explicitly specifies the number of
    # parameters to curry.
    #
    def reverse_curry(arity, &block)
      fail "cannot curry for unknown arity" if arity < 0
      Functors.make_reverse_curry(arity, &block)
    end

    #
    # Uncurry a curried closure.
    #
    def uncurry(&block)
      return block unless block.arity == 1
      proc do |*args|
        result = block
        args.each do |a|
          result = result.call(a)
        end
        result
      end
    end

    #
    # Uncurry a reverse curried closure.
    #
    def reverse_uncurry(&block)
      return block unless block.arity == 1
      proc do |*args|
        result = block
        args.reverse_each do |a|
          result = result.call(a)
        end
        result
      end
    end

    #
    # Create a Proc, when called,
    # repeatedly call _block_ for _n_ times.
    # The same arguments are passed to each invocation.
    #
    def repeat(n, &block)
      proc do |*args|
        result = nil
        n.times { result = block.call(*args) }
        result
      end
    end

    #
    # Create a Proc, when called,
    # repeatedly call _block_ for _n_ times.
    # At each iteration, return value from the previous iteration
    # is used as parameter.
    #
    def power(n, &block)
      return const(nil) if n <= 0
      return block if n == 1
      proc do |*args|
        result = block.call(*args)
        (n - 1).times { result = block.call(result) }
        result
      end
    end

    extend self

    def self.make_curry(arity, &block)
      return block if arity <= 1
      proc do |x|
        make_curry(arity - 1) do |*rest|
          block.call(*rest.insert(0, x))
        end
      end
    end

    def self.make_reverse_curry(arity, &block)
      return block if arity <= 1
      proc do |x|
        make_reverse_curry(arity - 1) do |*rest|
          block.call(*rest << x)
        end
      end
    end
  end
end # module
