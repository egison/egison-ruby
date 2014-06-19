require 'spec_helper'
require 'egison'

include Egison

describe "sample" do
  describe "combination.rb" do
    it %q{match_all([1,2,3,4,5]) do with(List.(*_, _x, *_, _y, *_)) { [x, y] } end} do
      expect(match_all([1,2,3,4,5]) do with(List.(*_, _x, *_, _y, *_)) { [x, y] } end).to eq \
        [[1, 2], [1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5]]
    end
    it %q{match_all([1,2,3,4,5]) do with(List.(*_, _x, *_, _y, *_, _z, *_)) { [x, y, z] } end} do
      expect(match_all([1,2,3,4,5]) do with(List.(*_, _x, *_, _y, *_, _z, *_)) { [x, y, z] } end).to eq \
        [[1, 2, 3], [1, 2, 4], [1, 2, 5], [1, 3, 4], [1, 3, 5], [1, 4, 5], [2, 3, 4], [2, 3, 5], [2, 4, 5], [3, 4, 5]]
    end
  end
end

