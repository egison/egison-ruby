## The Gem for Egison Pattern Matching 

Egison is the pattern-matching oriented pure functional programming langauge.
Egison is the world's first programming language that can pattern-match against sets.
This is the repository of the Ruby library to access Egison pattern-matching from Ruby.

For more information about Egison, visit [Egison web site](http://www.egison.org).

If you get interested in Egison, please mail to [Satoshi Egi](http://www.egison.org/~egi/) or tweet to [@__Egi](https://twitter.com/__Egi) or [@Egison_Lang](https://twitter.com/Egison_Lang).

## Demonstrations

### Three matchers: List, Multiset, Set

```
match_all([1, 2, 3]) do
  with(List.(a, b, ___)) do
    a #=> [[1, 2]]
  end
end
```

```
match_all([1, 2, 3]) do
  with(Multiset.(a, b, ___)) do
    a #=> [[1, 2],[1, 3],[2, 3]]
  end
end
```

```
match_all([1, 2, 3]) do
  with(Set.(a, b, __)) do
    a #=> [[1, 1],[1, 2],[1, 3],[2, 1],[2, 2],[2, 3],[3, 1],[3, 2],[3, 3]]
  end
end
```

### Three patterns: Nil pattern, Cons pattern, Join Pattern

A nil pattern matches when target is an empty array.

```
match_all([]) do
  with(List.()) do
    "matched" #=> "matched"
  end
end
```
A cons pattern divide the target to an element and the rest of elements.

```
match_all([1, 2, 3]) do
  with(List.(a, __b)) do
    [a, b] #=> [1,[2, 3]]
  end
end
```

```
match_all([1, 2, 3]) do
  with(Multiset.(a, __b)) do
    a #=> [[1,[2,3]],[2,[1,3]],[3,[1,2]]]
  end
end
```

```
match_all([1, 2, 3]) do
  with(Set.(a, __b)) do
    a #=> [[1,[1,2,3]],[2,[1,2,3]],[3,[1,2,3]]]
  end
end
```

A join pattern divide the target to two arrays.

```
match_all([1, 2, 3]) do
  with(List.(__a, __b)) do
    [a, b] #=> [[[],[1,2,3]],[[1],[2, 3]],[[1,2],[3]],[[1,2,3],[]]]
  end
end
```

### Non-linear patterns

Non-linear patterns are the most important feature of our pattern-mathcing system.

```
match_all([1, 2, 3, 2, 5]) do
  with(Multiset.(a, _a, ___)) do
    a #=> [2,2]
  end
end
```

```
match_all([30, 30, 20, 30, 20]) do
  with(Multiset.(a, _a, _a, b, _b)) do
    [a, b] #=> [[30,20], ...]
  end
end
```

```
match_all([5, 3, 4, 1, 2]) do
  with(Multiset.(a, _(a + 1), _(a + 2), __)) do
    a #=> [1, 3, 4]
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
    with(Multiset.([s, n], [_s, _(n + 1)], [_s, _(n + 2)], [_s, _(n + 3)], [_s, _(n + 4)])) do
      "Straight flush"
    end
    with(Multiset.([__, n], [__, _n], [__, _n], [__, _n], __)) do
      "Four of kind"
    end
    with(Multiset.([__, m], [__, _m], [__, _m], [__, _n], [__, _n])) do
      "Full house"
    end
    with(Multiset.([s, __], [s, __], [s, __], [s, __], [s, __])) do
      "Flush"
    end
    with(Multiset.([__, n], [__, _(n + 1)], [__, _(n + 2)], [__, _(n + 3)], [__, _(n + 4)])) do
      "Straight"
    end
    with(Multiset.([__, n], [__, _n], [__, _n], __, __)) do
      "Three of kind"
    end
    with(Multiset.([__, m], [__, _m], [__, n], [__, _n], __)) do
      "Two pairs"
    end
    with(Multiset.([__, n], [__, _n], __, __, __)) do
      "One pair"
    end
    with(Multiset.(__, __, __, __, __)) do
      "Nothing"
    end
end

poker_hands([["diamond", 1], ["club", 2], ["club", 1], ["heart", 1], ["diamond", 2]]) #=> "Full house"
poker_hands([["diamond", 4], ["club", 2], ["club", 5], ["heart", 1], ["diamond", 3]]) #=> "Straight"
poker_hands([["diamond", 4], ["club", 10], ["club", 5], ["heart", 1], ["diamond", 3]]) #=> "Nothing"
```

## LICENSE

The license of this library code is BSD.
I learned how to extend Ruby and how to write a gem from the code of [the pattern-match gem](https://github.com/k-tsj/pattern-match) by Kazuki Tsujimoto.
I designed syntax of pattern-matching to go with that gem.
I cannot write this library without that gem, since I am a beginner of meta programming in Ruby.
The full license text is [here](https://github.com/egisatoshi/egison-ruby/blob/master/LICENSE).
