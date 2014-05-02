require 'egison'

tgt = [1, 2, 3, 1, 4, 3]

p(match_all(tgt) do with(List.(_a, *_b)) { [a, b] } end)

p(match_all(tgt) do with(List.(_a, *_, _b, *_)) { [a, b] } end)

p(match_all(tgt) do with(List.(_a, *_, __a, *_)) { a } end)

p(match_all(tgt) do with(Multiset.(_a, *_b)) { [a, b] } end)

p(match_all(tgt) do with(Multiset.(_a, __a, *_)) { a } end)

tgt2 = [[1, 2], [3, 1], [4, 3]]

p(match_all(tgt2) do with(List.(_a, List.(_b, _), _)) { [a, b] } end)
