require 'spec_helper'
require 'egison'

include Egison

def nats
  (1..Float::INFINITY)
end

describe "sample" do
  describe "join_stream.rb" do
    # (take 30 (match-all nats (list integer) [<join $hs <join $ts _>> [hs ts]]))
    # => {[{} {}] [{} {1}] [{1} {}] [{} {1 2}] [{1} {2}] [{1 2} {}] [{} {1 2 3}] [{1} {2 3}] [{1 2} {3}] [{1 2 3} {}] [{} {1 2 3 4}] [{1} {2 3 4}] [{1 2} {3 4}] [{1 2 3} {4}] [{1 2 3 4} {}] [{} {1 2 3 4 5}] [{1} {2 3 4 5}] [{1 2} {3 4 5}] [{1 2 3} {4 5}] [{1 2 3 4} {5}] [{1 2 3 4 5} {}] [{} {1 2 3 4 5 6}] [{1} {2 3 4 5 6}] [{1 2} {3 4 5 6}] [{1 2 3} {4 5 6}] [{1 2 3 4} {5 6}] [{1 2 3 4 5} {6}] [{1 2 3 4 5 6} {}] [{} {1 2 3 4 5 6 7}] [{1} {2 3 4 5 6 7}]}
    # v- same result as above
    it %q{match_stream(nats) { with(List.(*_hs, *_ts, *_)) { [hs, ts] } }.take(30)} do
      expect(match_stream(nats) { with(List.(*_hs, *_ts, *_)) { [hs, ts] } }.take(30)).to eq \
        [[[], []], [[], [1]], [[1], []], [[], [1, 2]], [[1], [2]], [[1, 2], []], [[], [1, 2, 3]], [[1], [2, 3]], [[1, 2], [3]], [[1, 2, 3], []], [[], [1, 2, 3, 4]], [[1], [2, 3, 4]], [[1, 2], [3, 4]], [[1, 2, 3], [4]], [[1, 2, 3, 4], []], [[], [1, 2, 3, 4, 5]], [[1], [2, 3, 4, 5]], [[1, 2], [3, 4, 5]], [[1, 2, 3], [4, 5]], [[1, 2, 3, 4], [5]], [[1, 2, 3, 4, 5], []], [[], [1, 2, 3, 4, 5, 6]], [[1], [2, 3, 4, 5, 6]], [[1, 2], [3, 4, 5, 6]], [[1, 2, 3], [4, 5, 6]], [[1, 2, 3, 4], [5, 6]], [[1, 2, 3, 4, 5], [6]], [[1, 2, 3, 4, 5, 6], []], [[], [1, 2, 3, 4, 5, 6, 7]], [[1], [2, 3, 4, 5, 6, 7]]]
    end
    # (take 30 (match-all nats (multiset integer) [<join $hs <join $ts _>> [hs ts]]))
    # => {[{} {}] [{} {1}] [{1} {}] [{} {2}] [{1} {2}] [{2} {}] [{} {3}] [{1} {3}] [{2} {1}] [{3} {}] [{} {4}] [{1} {4}] [{2} {3}] [{3} {1}] [{4} {}] [{} {5}] [{1} {5}] [{2} {4}] [{3} {2}] [{4} {1}] [{5} {}] [{} {6}] [{1} {6}] [{2} {5}] [{3} {4}] [{4} {2}] [{5} {1}] [{6} {}] [{} {7}] [{1} {7}]}
    # v- diffrent result as above, but natural
    it %q{match_stream(nats) { with(Multiset.(*_hs, *_ts, *_)) { [hs, ts] } }.take(30)} do
      expect(match_stream(nats) { with(Multiset.(*_hs, *_ts, *_)) { [hs, ts] } }.take(30)).to eq \
        [[[], []], [[], [1]], [[1], []], [[], [2]], [[1], [2]], [[2], []], [[], [1, 2]], [[1], [3]], [[2], [1]], [[1, 2], []], [[], [3]], [[1], [2, 3]], [[2], [3]], [[1, 2], [3]], [[3], []], [[], [1, 3]], [[1], [4]], [[2], [1, 3]], [[1, 2], [4]], [[3], [1]], [[1, 3], []], [[], [2, 3]], [[1], [2, 4]], [[2], [4]], [[1, 2], [3, 4]], [[3], [2]], [[1, 3], [2]], [[2, 3], []], [[], [1, 2, 3]], [[1], [3, 4]]]
    end
    # (take 30 (match-all nats (set integer) [<join $hs <join $ts _>> [hs ts]]))
    # => {[{} {}] [{} {1}] [{1} {}] [{} {2}] [{1} {1}] [{2} {}] [{} {3}] [{1} {2}] [{2} {1}] [{3} {}] [{} {1 2}] [{1} {3}] [{2} {2}] [{3} {1}] [{1 2} {}] [{} {4}] [{1} {1 2}] [{2} {3}] [{3} {2}] [{1 2} {1}] [{4} {}] [{} {1 3}] [{1} {4}] [{2} {1 2}] [{3} {3}] [{1 2} {2}] [{4} {1}] [{1 3} {}] [{} {2 1}] [{1} {1 3}]}
    # v- diffrent result as above, but natural
    it %q{match_stream(nats) { with(Set.(*_hs, *_ts, *_)) { [hs, ts] } }.take(30)} do
      expect(match_stream(nats) { with(Set.(*_hs, *_ts, *_)) { [hs, ts] } }.take(30)).to eq \
        [[[], []], [[], [1]], [[1], []], [[], [2]], [[1], [1]], [[2], []], [[], [1, 2]], [[1], [2]], [[2], [1]], [[1, 2], []], [[], [3]], [[1], [1, 2]], [[2], [2]], [[1, 2], [1]], [[3], []], [[], [1, 3]], [[1], [3]], [[2], [1, 2]], [[1, 2], [2]], [[3], [1]], [[1, 3], []], [[], [2, 3]], [[1], [1, 3]], [[2], [3]], [[1, 2], [1, 2]], [[3], [2]], [[1, 3], [1]], [[2, 3], []], [[], [1, 2, 3]], [[1], [2, 3]]]
    end
  end
end
