require 'spec_helper'
require 'egison/core'
require 'egison/matcher'

describe "Constructor" do
  describe "List" do
    it "#uncons" do
      expect(
        List.uncons([1, 2, 3])
      ).to eq(
        [[1, [2, 3]]]
      )
    end

    it "#unjoin" do
      expect(
        List.unjoin([1, 2, 3])
      ).to eq(
        [[[], [1, 2, 3]], [[1], [2, 3]], [[1, 2], [3]], [[1, 2, 3], []]]
      )
    end
  end

  describe "Multiset" do
    it "#uncons" do
      expect(
        Multiset.uncons([1, 2, 3])
      ).to eq(
        [[1, [2, 3]], [2, [1, 3]], [3, [1, 2]]]
      )
    end

    it "#unjoin" do
      expect(
        Multiset.unjoin([1, 2, 3])
      ).to eq(
        [[[], [1, 2, 3]], [[3], [1, 2]], [[2], [1, 3]], [[2, 3], [1]], [[1], [2, 3]], [[1, 3], [2]], [[1, 2], [3]], [[1, 2, 3], []]]
      )
    end
  end

  describe "Set" do
    it "#uncons" do
      expect(
        Set.uncons([1, 2, 3])
      ).to eq(
        [[1, [1, 2, 3]], [2, [1, 2, 3]], [3, [1, 2, 3]]]
      )
    end

    it "#unjoin" do
      expect(
        Set.unjoin([1, 2, 3])
      ).to eq(
        [[[], [1, 2, 3]], [[3], [1, 2, 3]], [[2], [1, 2, 3]], [[2, 3], [1, 2, 3]], [[1], [1, 2, 3]], [[1, 3], [1, 2, 3]], [[1, 2], [1, 2, 3]], [[1, 2, 3], [1, 2, 3]]]
      )
    end
  end

  describe "Struct" do
    it "#unnil" do
      expect(
        Struct.unnil([1, 2, 3])
      ).to eq(
        [[]]
      )
    end

    it "#uncons" do
      expect(
        Struct.uncons([1, 2, 3])
      ).to eq(
        [[1, [2, 3]]]
      )
    end

    it "#unjoin" do
      expect(
        Struct.unjoin([1, 2, 3])
      ).to eq(
        [[[], [1, 2, 3]], [[1], [2, 3]], [[1, 2], [3]], [[1, 2, 3], []]]
      )
    end
  end
end
