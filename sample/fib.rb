require 'egison'

include Egison

def fib (n)
  match(n) do
    with(0) { 0 }
    with(1) { 1 }
    with(_) { fib(n - 1) + fib(n - 2) }
  end
end

p(fib(0))
p(fib(1))
p(fib(10))
