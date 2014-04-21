require 'egison'

match(10) do
  with(__a) { p a }
end

match(10) do
  with(_(10)) { p 10 }
end

match([100, 200]) do
  with(List.(__a, __b)) { p [a, b] }
end
