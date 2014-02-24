#require 'pattern-match'
require 'egison'

match(1) do
  with(_a) do
    p a
  end
end

match([1, 2, 3, 4, 5, 6, 7]) do
  with(Array.(*_, 2, *_a, 6, *_)) do
    p a
  end
end

match([1, 2, 3, 4, 5, 6, 7]) do
  with(_[*_, 2, *_a, 6, *_]) do
    p a
  end
end

match([[1, 2], [3, 4], [5, 6]]) do
  with(_[_, _[_a, _b], _]) do
    p(a, b)
  end
end
