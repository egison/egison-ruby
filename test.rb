require 'egison'

match(10) do
  with(__a) { p a }
end


x = match(10) do with(__a) { a } end
p x
