require 'egison'
require 'prime'

include Egison

twin_primes = match_stream(Prime) {
  with(List.(*_, _p, __("p + 2"), *_)) {
    [p, p + 2]
  }
}

p twin_primes.take(10)

prime_triplets = match_stream(Prime) {
  with(List.(*_, _p, And(Or(__("p + 2"), __("p + 4")), _m), __("p + 6"), *_)) {
    [p, m, p + 6]
  }
}

p prime_triplets.take(10)
