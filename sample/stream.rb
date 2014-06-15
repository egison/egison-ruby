require 'egison'
require 'prime'

p(match_stream(1..5){ with(List.(*_, _x, *_, _y, *_)) { [x, y] } }.to_a)

twin_primes = match_stream(Prime) {
  with(List.(*_, _x, __("x + 2"), *_)) {
    [x, x + 2]
  }
}

p twin_primes.take(10)

def nats
  (1..Float::INFINITY)
end

p match_stream(nats){ with(Multiset.(_m, _n, *_)) { [m, n] } }.take(10)

p match_stream(nats){ with(Set.(_m, _n, *_)) { [m, n] } }.take(10)
