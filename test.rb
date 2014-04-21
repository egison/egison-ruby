require 'egison'

match(10) do
  with(__a) { p a }
end

b = 2
x = match(10) do with(__a) { a + b } end
p x


match(10) do
  with(_(10)) { p 10 }
end

b = 10
x = match(10) do with(_(b)) { b } end
p x
