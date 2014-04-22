require 'egison'

match(10) do
  with(_a) { p a }
end

match(10) do
  with(__10) { p :ok }
end

match([20, 20]) do
  with(List.(_a, __a)) { p :ok2 }
end

match([100, 200]) do
  with(List.(_a, _b)) { p [a, b] }
end

match([1, 2, 3]) do
  with(List.(_a, _b, _c)) { p [a, b, c] }
end
