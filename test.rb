require 'egison'

match(10) do
  with(_a) { if a == 10 then p :ok end }
end

match(10) do
  with(__10) { p :ok }
end

match([100, 200]) do
  with(List.(_a, _b)) { if [a, b] == [100, 200] then p :ok end }
end

match([1, 2, 3]) do
  with(List.(_a, _b, _c)) { if [a, b, c] == [1, 2, 3] then p :ok end }
end

match([20, 20]) do
  with(List.(_a, __a)) { p :ok }
end

