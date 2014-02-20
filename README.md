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

## Acknowledgement

I learned how to extend Ruby and how to write a gem from the code of [the pattern-match gem](https://github.com/k-tsj/pattern-match) by Kazuki Tsujimoto.
I designed syntax of pattern-matching to go with that gem.
I cannot write this library without that gem, since I am a beginner of meta programming in Ruby.
