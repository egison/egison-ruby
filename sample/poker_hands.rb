require 'egison'

include Egison

def poker_hands cs
  match(cs) do
    with(Multiset.(_[_s, 10], _[__s, 11], _[__s, 12], _[__s, 13], _[__s, 1])) do
      "Royal Straight flush"
    end
    with(Multiset.(_[_s, _n], _[__s, __("n+1")], _[__s, __("n+2")], _[__s, __("n+3")], _[__s, __("n+4")])) do
      "Straight flush"
    end
    with(Multiset.(_[_, _n], _[_, __n], _[_, __n], _[_, __n], _)) do
      "Four of kind"
    end
    with(Multiset.(_[_, _m], _[_, __m], _[_, __m], _[_, _n], _[_, __n])) do
      "Full house"
    end
    with(Multiset.(_[_s, _], _[__s, _], _[__s, _], _[__s, _], _[__s, _])) do
      "Flush"
    end
    with(Multiset.(_[_, _n], _[_, __("n+1")], _[_, __("n+2")], _[_, __("n+3")], _[_, __("n+4")])) do
      "Straight"
    end
    with(Multiset.(_[_, _n], _[_, __n], _[_, __n], _, _)) do
      "Three of kind"
    end
    with(Multiset.(_[_, _m], _[_, __m], _[_, _n], _[_, __n], _)) do
      "Two pairs"
    end
    with(Multiset.(_[_, _n], _[_, __n], _, _, _)) do
      "One pair"
    end
    with(Multiset.(_, _, _, _, _)) do
      "Nothing"
    end
  end
end

p(poker_hands([["diamond", 1], ["diamond", 10], ["diamond", 13], ["diamond", 12], ["diamond", 11]])) #=> "Straight flush"
p(poker_hands([["diamond", 1], ["diamond", 3], ["diamond", 5], ["diamond", 4], ["diamond", 2]])) #=> "Straight flush"
p(poker_hands([["diamond", 1], ["club", 2], ["club", 1], ["heart", 1], ["diamond", 2]])) #=> "Full house"
p(poker_hands([["diamond", 4], ["club", 2], ["club", 5], ["heart", 1], ["diamond", 3]])) #=> "Straight"
p(poker_hands([["diamond", 4], ["club", 10], ["club", 5], ["heart", 1], ["diamond", 3]])) #=> "Nothing"
