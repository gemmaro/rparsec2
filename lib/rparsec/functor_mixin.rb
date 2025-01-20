module RParsec
  #
  # This module provides instance methods that
  # manipulate closures in a functional style.
  # It is typically included in Proc and Method.
  #
  module FunctorMixin
    #
    # Create a +Proc+, which expects the two parameters in the reverse
    # order of +self+.
    #
    def flip = Functors.flip(&self)

    #
    # Create a +Proc+, when called, the parameter is first passed into
    # +other+, +self+ is called in turn with the return value from
    # +other+.
    #
    def compose(other) = Functors.compose(self, other)
    alias << compose

    #
    # <tt>a >> b</tt> is equivalent to <tt>b << a</tt>.  See also #<<.
    #
    def >>(other) = other << self

    #
    # Create a Proc that's curriable.
    # When curried, parameters are passed in from left to right.
    # i.e. closure.curry.call(a).call(b) is quivalent to closure.call(a,b) .
    # _self_ is encapsulated under the hood to perform the actual
    # job when currying is done.
    # _ary_ explicitly specifies the number of parameters to curry.
    #
    # *IMPORTANT*
    # Proc and Method have built-in curry.
    # but the arity always return -1.
    # So, curry.reverse_curry does not work as expected.
    # You need to use the "using FunctorMixin"
    # See the "functor_test.rb"
    [Proc, Method].each do |klass|
      refine klass do
        def curry(ary = arity) = Functors.curry(ary, &self)
      end
    end

    #
    # Create a +Proc+ that's curriable.  When curried, parameters are
    # passed in from right to left.
    # i.e. <tt>closure.reverse_curry.call(a).call(b)</tt> is quivalent
    # to <tt>closure.call(b, a)</tt>.  +self+ is encapsulated under
    # the hood to perform the actual job when currying is done.  +ary+
    # explicitly specifies the number of parameters to curry.
    #
    def reverse_curry(ary = arity) = Functors.reverse_curry(ary, &self)

    #
    # Uncurry a curried closure.
    #
    def uncurry = Functors.uncurry(&self)

    #
    # Uncurry a reverse curried closure.
    #
    def reverse_uncurry = Functors.reverse_uncurry(&self)

    #
    # Create a +Proc+, when called, repeatedly call +self+ for +n+
    # times.  The same arguments are passed to each invocation.
    #
    def repeat(n) = Functors.repeat(n, &self)
    alias * repeat

    # Create a +Proc+, when called, repeatedly call +self+ for +n+
    # times.  At each iteration, return value from the previous
    # iteration is used as parameter.
    #
    def power(n) = Functors.power(n, &self)
    alias ** power
  end
end
