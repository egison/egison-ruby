require 'egison'
require 'prime'

include Egison

twin_primes = match_stream(Prime) {
  with(List.(*_, _x, __("x + 2"), *_)) {
    [x, x + 2]
  }
}

p twin_primes.take(10)
