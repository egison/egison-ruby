require 'egison'
require 'prime'

p(match_stream(1..5){ with(List.(*_, _x, *_, _y, *_)) { [x, y] } }.to_a)

twin_primes = match_stream(Prime) {
  with(List.(*_, _x, __("x + 2"), *_)) {
    [x, x + 2]
  }
}

p twin_primes.take(10)
