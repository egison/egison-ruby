require 'spec_helper'
require 'egison'

describe "egison" do
  describe "#match_all" do
    describe "List" do
      it "ex1" do
        expect(
          match_all([1, 2, 3]) do
            with(List.(_a, _b, *_)) do
              [a, b]
            end
          end
        ).to eq([[1, 2]])
      end
    end

    describe "Multiset" do
      it "ex1" do
        expect(
          match_all([1, 2, 3]) do
            with(Multiset.(_a, _b, *_)) do
              [a, b]
            end
          end
        ).to eq([[1, 2], [1, 3], [2, 1], [2, 3], [3, 1], [3, 2]])
      end
    end

    describe "Set" do
      it "ex1" do
        expect(
          match_all([1, 2, 3]) do
            with(Set.(_a, _b, *_)) do
              [a, b]
            end
          end
        ).to eq([[1, 1],[1, 2],[1, 3],[2, 1],[2, 2],[2, 3],[3, 1],[3, 2],[3, 3]])
      end
    end
  end

  describe "#match" do
    describe "List" do
      it "ex1" do
        expect(
          match_single([1, 2, 3]) do
            with(List.(_a, _b, *_)) { true }
          end
        ).to eq(true)
      end
    end

    describe "Multiset" do
      it "ex1" do
        expect(
          match_single([1, 2, 3]) do
            with(Multiset.(_a, _b, *_)) { true }
          end
        ).to eq(true)
      end
    end

    describe "Set" do
      it "ex1" do
        expect(
          match_single([1, 2, 3]) do
            with(Set.(_a, _b, *_)) { true }
          end
        ).to eq(true)
      end
    end
  end
end
