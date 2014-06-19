require 'spec_helper'
require 'egison'

include Egison

describe "sample" do
  describe "set.rb" do
    it %q{match_all([1,2,3,4,5]) do with(Set.(_x,_y, *_)) { [x, y] } end} do
      expect(match_all([1,2,3,4,5]) do with(Set.(_x,_y, *_)) { [x, y] } end).to eq \
        [[1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5]]
    end
  end
end

