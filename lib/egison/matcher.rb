require 'egison/core'
require 'egison/lazyarray'
require 'egison/matcher-core'
require 'set'

module Egison
  extend self
  
  class Multiset
  end

  class << Multiset
    def uncons(val)
      match_all(val) do
        with(List.(*_hs, _x, *_ts)) do
          [x, hs + ts]
        end
      end
    end

    def uncons_stream(val, &block)
      if !(val.kind_of?(Array) || val.kind_of?(Egison::LazyArray))
        val = test_conv_lazy_array(val)
      end
      stream = match_stream(val) {
        with(List.(*_hs, _x, *_ts)) do
          [x, hs + ts]
        end
      }
      stream.each(&block)
    end

    def unjoin(val)
      val2 = val.clone
      xs = []
      ys = val2.clone
      rets = [[xs, ys]]
      if val2.empty?
        rets
      else
        x = val2.shift
        ys = val2.clone
        rets2 = unjoin(ys)
        rets = (rets2.map { |xs2, ys2| [xs2, [x] + ys2] }) + (rets2.map { |xs2, ys2| [[x] + xs2, ys2] })
        rets
      end
    end

    def unjoin_stream(val, &block)
      if !(val.kind_of?(Array) || val.kind_of?(Egison::LazyArray))
        val = test_conv_lazy_array(val)
      end
      val2 = val.clone
      xs = []
      ys = val2.clone
      block.([xs, ys])
      unless val2.empty?
        x = val2.shift
        ys = val2.clone
        unjoin_stream(ys) do |xs2, ys2|
          block.([xs2, [x] + ys2]) unless xs2.empty?
          block.([[x] + xs2, ys2])
        end
      end
    end
  end

  class << Set
    def uncons(val)
      match_all(val) do
        with(List.(*_, _x, *_)) do
          [x, val]
        end
      end
    end

    def uncons_stream(val, &block)
      if !(val.kind_of?(Array) || val.kind_of?(Egison::LazyArray))
        val = test_conv_lazy_array(val)
      end
      stream = match_stream(val) {
        with(List.(*_, _x, *_)) do
          [x, val]
        end
      }
      stream.each(&block)
    end

    def unjoin(val)
      val2 = val.clone
      xs = []
      ys = val2.clone
      rets = [[xs, ys]]
      if val2.empty?
        rets
      else
        x = val2.shift
        ys2 = val2.clone
        rets2 = unjoin(ys2)
        rets = (rets2.map { |xs2, _| [xs2, ys] }) + (rets2.map { |xs2, ys2| [[x] + xs2, ys] })
        rets
      end
    end

    def unjoin_stream(val, &block)
      if !(val.kind_of?(Array) || val.kind_of?(Egison::LazyArray))
        val = test_conv_lazy_array(val)
      end
      val2 = val.clone
      xs = []
      ys = val2.clone
      block.([xs, ys])
      unless val2.empty?
        x = val2.shift
        ys2 = val2.clone
        unjoin_stream(ys2) do |xs2, _|
          block.([xs2, ys]) unless xs2.empty?
          block.([[x] + xs2, ys])
        end
      end
    end
  end
end
