require 'egison'

match([1, 2, 3, 4, 5]) do
  with(_[*_, *a, *_], guard { a.inject(:*) == 12 }) do
    a #=> [3, 4]
  end
end
