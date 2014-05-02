require 'egison'

#ret1 = match_all(10) do with(_a) { a } end
#p ret1

#ret2 = match_all(10) do with(__10) { :ok } end
#p ret2

#ret3 = match_all([100, 200, 300]) do with(List.(_a, _b, _c)) { [a, b, c] } end
#p ret3

#ret4 = match_all([100, 200, 300]) do with(Multiset.(_a, _b, _c)) { [a, b, c] } end
#p ret4

#ret5 = match_all([20, 20]) do with(List.(_a, __a)) { :ok } end
#p ret5

#ret6 = match_all([100, 200, 100]) do with(Multiset.(_a, __a, _b)) { [a, b] } end
#p ret6#=>[[100, 200], [100, 200]]

ret7 = match_all([1, 2, 3, 1, 4]) do with(List.(_a, *_b)) { [a, b] } end
p ret7

ret8 = match_all([1, 2, 3, 1, 4]) do with(List.(_a, *_, _b, *_)) { [a, b] } end
p ret8

ret9 = match_all([1, 2, 3, 1, 4]) do with(List.(_a, *_, __a, *_)) { a } end
p ret9

ret10 = match_all([1, 2, 3, 1, 4]) do with(Multiset.(_a, *_b)) { [a, b] } end
p ret10

ret10 = match_all([1, 2, 3, 1, 4, 3]) do with(Multiset.(_a, __a, *_)) { a } end
p ret10
