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

```
match_all([1, 2, 3]) do
  with(List.(*_hs, _x, *_ts)) do
    [a, b] #=> [[[],1,[2,3]],[[1],2,[3]],[[1,2],3,[]]
  end
end
```

### Three matchers: List, Multiset, Set

```
match_all([1, 2, 3]) do
  with(List.(_a, _b, *_)) do
    a #=> [[1, 2]]
  end
end
```

```
match_all([1, 2, 3]) do
  with(Multiset.(_a, _b, *_)) do
    a #=> [[1, 2],[1, 3],[2, 3]]
  end
end
```

```
match_all([1, 2, 3]) do
  with(Set.(_a, _b, *_)) do
    a #=> [[1, 1],[1, 2],[1, 3],[2, 1],[2, 2],[2, 3],[3, 1],[3, 2],[3, 3]]
  end
end
```

```
match_all([1, 2, 3]) do
  with(List.(_a, *_b)) do
    [a, b] #=> [1,[2, 3]]
  end
end
```

```
match_all([1, 2, 3]) do
  with(Multiset.(_a, *_b)) do
    a #=> [[1,[2,3]],[2,[1,3]],[3,[1,2]]]
  end
end
```

```
match_all([1, 2, 3]) do
  with(Set.(_a, *_b)) do
    a #=> [[1,[1,2,3]],[2,[1,2,3]],[3,[1,2,3]]]
  end
end
```

### Non-linear patterns

Non-linear patterns are the most important feature of our pattern-mathcing system.
Patterns which don't have `_` ahead of them are value patterns.
It matches the target when the target is equal with it.

```
match_all([1, 2, 3, 2, 5]) do
  with(Multiset.(_a, a, *_)) do
    a #=> [2,2]
  end
end
```

```
match_all([30, 30, 20, 30, 20]) do
  with(Multiset.(_a, a, a, _b, b)) do
    [a, b] #=> [[30,20], ...]
  end
end
```

```
match_all([5, 3, 4, 1, 2]) do
  with(Multiset.(_a, (a + 1), (a + 2), *_)) do
    a #=> [1,2,3]
  end
end
```

## Poker Hands

We write a poker-hands demonstration as Egison. (http://www.egison.org/demonstrations/poker-hands.html)
It is as follow.
Egison is the world first and only language that can write all poker-hands in a single pattern.
Now Ruby too!

```
def poker_hands cs
  match([5, 3, 4, 1, 2]) do
    with(Multiset.(_[_s, _n], _[s, (n + 1)], _[s, (n + 2)], _[s, (n + 3)], _[s, (n + 4)])) do
      "Straight flush"
    end
    with(Multiset.(_[_, _n], _[_, n], _[_, n], _[_, n], _)) do
      "Four of kind"
    end
    with(Multiset.(_[_, _m], _[_, m], _[_, m], _[_, _n], _[_, n])) do
      "Full house"
    end
    with(Multiset.(_[_s, _], _[s, _], _[s, _], _[s, _], _[s, _])) do
      "Flush"
    end
    with(Multiset.(_[_, _n], _[_, (n + 1)], _[_, (n + 2)], _[_, (n + 3)], _[_, (n + 4)])) do
      "Straight"
    end
    with(Multiset.(_[_, _n], _[_, n], _[_, n], _, _)) do
      "Three of kind"
    end
    with(Multiset.(_[_, _m], _[_, m], _[_, _n], _[_, n], _)) do
      "Two pairs"
    end
    with(Multiset.(_[_, _n], _[_, n], _, _, _)) do
      "One pair"
    end
    with(Multiset.(_, _, _, _, _)) do
      "Nothing"
    end
  end
end

poker_hands([["diamond", 1], ["club", 2], ["club", 1], ["heart", 1], ["diamond", 2]]) #=> "Full house"
poker_hands([["diamond", 4], ["club", 2], ["club", 5], ["heart", 1], ["diamond", 3]]) #=> "Straight"
poker_hands([["diamond", 4], ["club", 10], ["club", 5], ["heart", 1], ["diamond", 3]]) #=> "Nothing"
```

## About Egison

If you get to love the above pattern-mathcing, please try [Egison](http://www.egison.org), too.
It is more powerful.
For example, programmers can define their own matcher in Egison.
(In Egison, the list, multiset, and set matchers are defined in the library not builtin.)
We can pattern-match against infinite lists.
There is a new programming world!

## LICENSE

The license of this library code is BSD.
I learned how to extend Ruby and how to write a gem from the code of [the pattern-match gem](https://github.com/k-tsj/pattern-match) by Kazuki Tsujimoto.
I designed syntax of pattern-matching to go with that gem.
I cannot write this library without that gem, since I am a beginner of meta programming in Ruby.
The full license text is [here](https://github.com/egisatoshi/egison-ruby/blob/master/LICENSE).
