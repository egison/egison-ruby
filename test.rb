require 'egison'

ret1 = match_all(10) do with(_a) { a } end
p ret1

ret2 = match_all(10) do with(__10) { :ok } end
p ret2

ret3 = match_all([100, 200, 300]) do with(List.(_a, _b, _c)) { [a, b, c] } end
p ret3

ret4 = match_all([100, 200, 300]) do with(Multiset.(_a, _b, _c)) { [a, b, c] } end
p ret4

ret5 = match_all([20, 20]) do with(List.(_a, __a)) { :ok } end
p ret5

ret6 = match_all([100, 200, 100]) do with(Multiset.(_a, __a, _b)) { [a, b] } end
p ret6#=>[[100, 200], [100, 200]]
