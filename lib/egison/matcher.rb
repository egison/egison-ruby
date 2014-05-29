require 'egison/core'
require 'egison/matcher-core'
require 'set'

class Multiset
end

class << Multiset
  def uncons(val)
    accept_array_only(val)
    match_all(val) do
      with(List.(*_hs, _x, *_ts)) do
        [x, hs + ts]
      end
    end
  end

  def unjoin(val)
    accept_array_only(val)
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
end

class << Set
  def uncons(val)
    accept_array_only(val)
    match_all(val) do
      with(List.(*_, _x, *_)) do
        [x, val]
      end
    end
  end

  def unjoin(val)
    accept_array_only(val)
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
end
