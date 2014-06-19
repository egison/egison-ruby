require 'egison'

include Egison

p(match_all([1,2,3,4,5]) do with(List.(*_hs, *_ts)) { [hs, ts] } end)

p(match_all([1,2,3,4,5]) do with(Multiset.(*_hs, *_ts)) { [hs, ts] } end)

p(match_all([1,2,3,4,5]) do with(Set.(*_hs, *_ts)) { [hs, ts] } end)
