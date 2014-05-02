require 'egison'

tgt = [1, 2, 3]

p(match_all(tgt) do with(List.(_a, *_b)) { [a, b] } end)

p(match_all(tgt) do with(List.(_a, *_, _b, *_)) { [a, b] } end)

p(match_all(tgt) do with(Multiset.(_a, *_b)) { [a, b] } end)

tgt2 = [1, 2, 3, 1, 4, 3]

p(match_all(tgt2) do with(List.(_a, *_, __a, *_)) { a } end)

p(match_all(tgt2) do with(Multiset.(_a, __a, *_)) { a } end)

p(match_all(tgt2) do with(Multiset.(_a, __a_plus_1, *_)) { a } end)

tgt3 = [["d", 1], ["c", 2], ["c", 1], ["h", 1], ["d", 2]]

p(match(tgt3) do
    with(Multiset.(List.(_, _x), List.(_, __x), List.(_, __x), List.(_, __x), *_)) { [4, x] }
    with(Multiset.(List.(_, _x), List.(_, __x), List.(_, __x), *_)) { [3, x] }
  end)
