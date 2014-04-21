require 'egison'

match(10) do
  with(_a) { p a }
end

match(10) do
  with(_{10}) { p 10 }
end

match([100, 200]) do
  with(List.(_a, _b)) { p [a, b] }
end

match([1, 2, 3, 4, 5, 6, 7]) do
  with(List.(_a, _b)) { p [a, b] }
end
