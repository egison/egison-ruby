require 'egison'

ret1 = match_all(10) do with(_a) { a } end
p ret1

ret2 = match_all(10) do with(__10) { :ok } end
p ret2

match_all([100, 200]) do
  with(List.(_a, _b)) { if [a, b] == [100, 200] then p :ok end }
end

match_all([1, 2, 3]) do
  with(List.(_a, _b, _c)) { if [a, b, c] == [1, 2, 3] then p :ok end }
end

match_all([20, 20]) do
  with(List.(_a, __a)) { p :ok }
end

