require 'egison'

include Egison

p(match_all([1,2,3,4,5]) do with(List.(*_, _x, *_, _y, *_)) { [x, y] } end)

p(match_all([1,2,3,4,5]) do with(List.(*_, _x, *_, _y, *_, _z, *_)) { [x, y, z] } end)
