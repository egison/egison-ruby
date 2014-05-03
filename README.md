## The Gem for Egison Pattern Matching 

Egison is the pattern-matching oriented pure functional programming langauge.
Egison is the world's first programming language that can represent non-linear pattern-match against unfree data types such as sets.
This is the repository of the Ruby library to access Egison pattern-matching from Ruby.

For more information about Egison, visit [Egison web site](http://www.egison.org).

If you get interested in Egison, please mail to [Satoshi Egi](http://www.egison.org/~egi/) or tweet to [@__Egi](https://twitter.com/__Egi) or [@Egison_Lang](https://twitter.com/Egison_Lang).

## Installation

```
$ gem build egison.gemspec
$ gem install egison-*.gem
```

## Demonstrations

### Element patterns and Subcollection patterns

A element pattern matches the element of the target array.

A subcollection pattern matches the subcollection of the target array.
A subcollection pattern has `*` ahead.

Literals that contain `_` ahead are pattern-variables.
We can refer the result of pattern-matching through them.

```
match_all([1, 2, 3]) do
  with(List.(*_hs, _x, *_ts)) do
    [hs, x, ts] #=> [[[],1,[2,3]],[[1],2,[3]],[[1,2],3,[]]
  end
end
```

### Three matchers: List, Multiset, Set

```
match([1, 2, 3]) do
  with(List.(_a, _b, *_)) do
    [a, b] #=> [[1, 2]]
  end
end

match_all([1, 2, 3]) do
  with(Multiset.(_a, _b, *_)) do
    a #=> [[1, 2],[1, 3],[2, 3]]
  end
end

match_all([1, 2, 3]) do
  with(Set.(_a, _b, *_)) do
    a #=> [[1, 1],[1, 2],[1, 3],[2, 1],[2, 2],[2, 3],[3, 1],[3, 2],[3, 3]]
  end
end
```

### Non-linear patterns

Non-linear patterns are the most important feature of our pattern-mathcing system.
Patterns which have `__` ahead of them are value patterns.
It matches the target when the target is equal with it.

```
match_all([1, 2, 3, 2, 5]) do
  with(Multiset.(_a, __a, *_)) do
    a #=> [2,2]
  end
end
```

```
match_all([30, 30, 20, 30, 20]) do
  with(Multiset.(_a, __a, __a, _b, __b)) do
    [a, b] #=> [[30,20], ...]
  end
end
```

```
match_all([5, 3, 4, 1, 2]) do
  with(Multiset.(_a, __("a + 1"), __("a + 2"), *_)) do
    a #=> [1,2,3]
  end
end
```

## Poker Hands

We can write patterns for all poker-hands in one single pattern.
It is as follow.
Isn't it exciting?

```
require 'egison'

def poker_hands cs
  match(cs) do
    with(Multiset.(_[_s, _n], _[__s, __("n+1")], _[__s, __("n+2")], _[__s, __("n+3")], _[__s, __("n+4")])) do
      "Straight flush"
    end
    with(Multiset.(_[_, _n], _[_, __n], _[_, __n], _[_, __n], _)) do
      "Four of kind"
    end
    with(Multiset.(_[_, _m], _[_, __m], _[_, __m], _[_, _n], _[_, __n])) do
      "Full house"
    end
    with(Multiset.(_[_s, _], _[__s, _], _[__s, _], _[__s, _], _[__s, _])) do
      "Flush"
    end
    with(Multiset.(_[_, _n], _[_, __("n+1")], _[_, __("n+2")], _[_, __("n+3")], _[_, __("n+4")])) do
      "Straight"
    end
    with(Multiset.(_[_, _n], _[_, __n], _[_, __n], _, _)) do
      "Three of kind"
    end
    with(Multiset.(_[_, _m], _[_, __m], _[_, _n], _[_, __n], _)) do
      "Two pairs"
    end
    with(Multiset.(_[_, _n], _[_, __n], _, _, _)) do
      "One pair"
    end
    with(Multiset.(_, _, _, _, _)) do
      "Nothing"
    end
  end
end

p(poker_hands([["diamond", 1], ["diamond", 3], ["diamond", 5], ["diamond", 4], ["diamond", 2]])) #=> "Straight flush"
p(poker_hands([["diamond", 1], ["club", 2], ["club", 1], ["heart", 1], ["diamond", 2]])) #=> "Full house"
p(poker_hands([["diamond", 4], ["club", 2], ["club", 5], ["heart", 1], ["diamond", 3]])) #=> "Straight"
p(poker_hands([["diamond", 4], ["club", 10], ["club", 5], ["heart", 1], ["diamond", 3]])) #=> "Nothing"
```

## About Egison

If you get to love the above pattern-mathcing, please try [Egison](http://www.egison.org), too.
It is more powerful.
For examplke ,we can pattern-match against infinite lists.
There is a new programming world!

## LICENSE

The license of this library code is BSD.
I learned how to extend Ruby and how to write a gem from the code of [the pattern-match gem](https://github.com/k-tsj/pattern-match) by Kazuki Tsujimoto.
I designed syntax of pattern-matching to go with that gem.
This library contains the copy from that gem.
The full license text is [here](https://github.com/egisatoshi/egison-ruby/blob/master/LICENSE).
