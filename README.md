## The Gem for Egison Pattern Matching 

This Gem provides a way to access Egison pattern-matching from Ruby.
Egison is the world's first programming language that can represent non-linear pattern-match against unfree data types.
We can directly express pattern-matching against lists, multisets, and sets using this gem.

## Installation

```
$ gem install egison
```

or

```
$ git clone git://github.com/egison/egison-ruby.git
$ cd egison-ruby
$ gem build egison.gemspec
$ gem install egison-*.gem
```

or

```
$ gem install bundler (if you need)
$ echo "gem 'egison', :git => 'git://github.com/egison/egison-ruby.git'" > Gemfile
$ bundle install --path vendor/bundle
```

== Basic Usage

egison library provides `Kernel#match` and  `Kernel#match_all`.

```
require 'egison'

match_all(object) do
  with(pattern) do
    ...
  end
end

match(object) do
  with(pattern) do
    ...
  end
  with(pattern) do
    ...
  end
  ...
end
```

If a pattern matches, a block passed to `with` is called and return its result.

In our pattern-matching system, there are cases that pattern-matching has multiple results.
`match_all` calls the block passed to `with` for each pattern-matching result and returns all results as an array.
`match_all` takes one single match-clause (`width`).

On the other hand, `match` takes multiple match-clauses.
It pattern-matches from the first match-clause.
If a pattern matches, it calls the block passed to matched match-clause and returns a result for the first pattern-matching result.

## Patterns

### Element patterns and subcollection patterns

An element pattern matches the element of the target array.

A subcollection pattern matches the subcollection of the target array.
A subcollection pattern has `*` ahead.

Literals that contain `_` ahead are pattern-variables.
We can refer the result of pattern-matching through them.

```
match_all([1, 2, 3]) do
  with(List.(*_hs, _x, *_ts)) do
    [hs, x, ts]
  end
end  #=> [[[],1,[2,3]],[[1],2,[3]],[[1,2],3,[]]
```

### Three matchers: List, Multiset, Set

We can write pattern-matching against lists, multisets, and sets.
When we regard an array as a multiset, the order of elements is ignored.
When we regard an array as a set, the duplicates and order of elements are ignored.

```
match_all([1, 2, 3]) do
  with(List.(_a, _b, *_)) do
    [a, b]
  end
end  #=> [[1, 2]]

match_all([1, 2, 3]) do
  with(Multiset.(_a, _b, *_)) do
    [a, b]
  end
end  #=> [[1, 2], [1, 3], [2, 1], [2, 3], [3, 1], [3, 2]]

match_all([1, 2, 3]) do
  with(Set.(_a, _b, *_)) do
    [a, b]
  end
end  #=> [[1, 1],[1, 2],[1, 3],[2, 1],[2, 2],[2, 3],[3, 1],[3, 2],[3, 3]]
```

### Non-linear patterns

Non-linear pattern is the most important feature of our pattern-matching system.
Our pattern-matching system allows users multiple occurrences of same variables in a pattern.
A Pattern whose form is `__("...")` is a value pattern.
In the place of `...`, we can write any ruby expression we like.
It matches the target when the target is equal with the value that `...` evaluated to.

```
match_all([5, 3, 4, 1, 2]) do
  with(Multiset.(_a, __("a + 1"), __("a + 2"), *_)) do
    a
  end
end  #=> [1,2,3]
```

When, the expression in the place of `...` is a single variable, we can omit `("` and `")` as follow.

```
match_all([1, 2, 3, 2, 5]) do
  with(Multiset.(_a, __a, *_)) do
    a
  end
end  #=> [2,2]
```

## Demonstration - Poker Hands

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

If you get to love the above pattern-matching, please try [Egison](http://www.egison.org), too.
Egison is the pattern-matching oriented pure functional programming language.
Actually, the original pattern-matching system of Egison is more powerful.
For example, we can do following things in the original Egison.

- We can pattern-match against infinite lists
- We can define new pattern-constructors.
- We can modularize useful patterns.

There is a new programming world!

## Contact

If you get interested in this Gem, please mail to [Satoshi Egi](http://www.egison.org/~egi/) or tweet to [@Egison_Lang](https://twitter.com/Egison_Lang).

## LICENSE

The license of this library code is BSD.
I learned how to extend Ruby and how to write a gem from the code of [the pattern-match gem](https://github.com/k-tsj/pattern-match) by Kazuki Tsujimoto.
I designed syntax of pattern-matching to go with that gem.
This library contains the copy from that gem.
The full license text is [here](https://github.com/egisatoshi/egison-ruby/blob/master/LICENSE).
