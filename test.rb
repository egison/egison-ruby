require 'egison'

match([1, 2, 3, 4, 5, 6, 7]) do
  with(_[*_, 2, *a, 6, *_]) do
    p a
  end
end
