require 'egison'

p(match_all([1,2,3,4,5]) do with(Set.(_x,_y, *_)) { [x, y] } end)
