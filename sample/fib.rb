require 'egison'

include Egison

def fib (n)
  match(n) do
    with(__0) { 1 }
    with(__1) { 1 }
    with(__) { fib(n - 1) + fib(n - 2) }
  end
end

p(fib(0))
p(fib(1))
p(fib(2))
p(fib(3))
p(fib(4))
p(fib(5))
p(fib(6))
