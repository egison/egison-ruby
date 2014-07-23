require 'egison'

include Egison

p(match_stream(1..5){ with(List.(*_, _x, *_, _y, *_)) { [x, y] } }.to_a)

p(match_stream(1..5){ with(List.(*_, 2, *_, _y, *_)) { [2, y] } }.to_a)

def nats
  (1..Float::INFINITY)
end

p match_stream(nats){ with(Multiset.(_m, _n, *_)) { [m, n] } }.take(10)

p match_stream(nats){ with(Set.(_m, _n, *_)) { [m, n] } }.take(10)
