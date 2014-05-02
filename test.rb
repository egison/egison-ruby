require 'egison'

tgt = [1, 2, 3, 1, 4, 3]

p(match_all(tgt) do with(List.(_a, *_b)) { [a, b] } end)

p(match_all(tgt) do with(List.(_a, *_, _b, *_)) { [a, b] } end)

p(match_all(tgt) do with(List.(_a, *_, __a, *_)) { a } end)

p(match_all(tgt) do with(Multiset.(_a, *_b)) { [a, b] } end)

p(match_all(tgt) do with(Multiset.(_a, __a, *_)) { a } end)

p(match_all(tgt) do with(Multiset.(_a, __a_plus_1, *_)) { a } end)

tgt2 = [[1, 2], [3, 1], [4, 3]]

p(match_all(tgt2) do with(List.(_a, List.(_b, _), _)) { [a, b] } end)

def poker_hands cs
  match_all(cs) do
    with(Multiset.(_[_, _n], _[_, __n], _[_, __n], _, _)) do
      n
    end
  end
end

p(poker_hands([["diamond", 1], ["club", 2], ["club", 1], ["heart", 1], ["diamond", 2]])) #=> "Full house"

p(match_all([["diamond", 1], ["club", 2], ["club", 1], ["heart", 1], ["diamond", 2]]) do with(Multiset.(_[_, _m], _[_, _n], _[_, _], _, _)) { [m, n] } end)

p(match_all([["diamond", 1], ["club", 2], ["club", 1], ["heart", 1], ["diamond", 2]]) do with(Multiset.(_m, _n, _[_, _], _, _)) { [m, n] } end)
