# The Gem for Egison Pattern Matching

This Gem provides a way to access non-linear pattern-matching against unfree data types from Ruby.
We can directly express pattern-matching against lists, multisets, and sets using this gem.

## Installation

```shell
$ gem install egison
```

or

```shell
$ git clone https://github.com/egison/egison-ruby.git
$ cd egison-ruby
$ make
```

or

```shell
$ gem install bundler (if you need)
$ echo "gem 'egison', :git => 'https://github.com/egison/egison-ruby.git'" > Gemfile
$ bundle install
```

## Basic Usage

The library provides `Egison#match_all` and  `Egison#match`.

```Ruby
require 'egison'

include Egison

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

If a pattern matches, a block passed to `with` is called and returns its result.

In our pattern-matching system, there are cases that pattern-matching has multiple results.
`match_all` calls the block passed to `with` for each pattern-matching result and returns all results as an array.
`match_all` takes one single match-clause.

On the other hand, `match` takes multiple match-clauses.
It pattern-matches from the first match-clause.
If a pattern matches, it calls the block passed to the matched match-clause and returns a result for the first pattern-matching result.

## Patterns

### Element Patterns and Subcollection Patterns

An <i>element pattern</i> matches the element of the target array.

A <i>subcollection pattern</i> matches the subcollection of the target array.
A subcollection pattern has `*` ahead.

A literal that contain `_` ahead is a <i>pattern-variable</i>.
We can refer the result of pattern-matching through them.

```Ruby
match_all([1, 2, 3]) do
  with(List.(*_hs, _x, *_ts)) do
    [hs, x, ts]
  end
end  #=> [[[],1,[2,3]],[[1],2,[3]],[[1,2],3,[]]
```

### Three Matchers: List, Multiset, Set

We can write pattern-matching against lists, multisets, and sets.
When we regard an array as a multiset, the order of elements is ignored.
When we regard an array as a set, the duplicates and order of elements are ignored.

`_` is a <i>wildcard</i>.
It matches with any object.
Note that `__` and `___` are also interpreted as a wildcard.
This is because `_` and `__` are system variables and sometimes have its own meaning.

```Ruby
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

Note that `_[]` is provided as syntactic sugar for `List.()`.

```Ruby
match_all([1, 2, 3]) do
  with(_[_a, _b, *_]) do
    [a, b]
  end
end  #=> [[1, 2]]
```

### Non-Linear Patterns

Non-linear pattern is the most important feature of our pattern-matching system.
Our pattern-matching system allows users multiple occurrences of same variables in a pattern.
A Pattern whose form is `__("...")` is a value pattern.
In the place of `...`, we can write any ruby expression we like.
It matches the target when the target is equal with the value that `...` evaluated to.

```Ruby
match_all([5, 3, 4, 1, 2]) do
  with(Multiset.(_a, __("a + 1"), __("a + 2"), *_)) do
    a
  end
end  #=> [1,2,3]
```

When, the expression in the place of `...` is a single variable, we can omit `("` and `")` as follow.

```Ruby
match_all([1, 2, 3, 2, 5]) do
  with(Multiset.(_a, __a, *_)) do
    a
  end
end  #=> [2,2]
```

### Pattern Matching against Stream (Infinite List)

We can do pattern-matching against streams with the `match_stream` expression.

```Ruby
def nats
  (1..Float::INFINITY)
end

match_stream(nats){ with(Multiset.(_m, _n, *_)) { [m, n] } }.take(10)
#=>[[1, 2], [1, 3], [2, 1], [1, 4], [2, 3], [3, 1], [1, 5], [2, 4], [3, 2], [4, 1]]

match_stream(nats){ with(Set.(_m, _n, *_)) { [m, n] } }.take(10)
#=>[[1, 1], [1, 2], [2, 1], [1, 3], [2, 2], [3, 1], [1, 4], [2, 3], [3, 2], [4, 1]]
```

## Demonstrations

### Combinations

We can enumerates all combinations of the elements of a collection with pattern-matching.

```Ruby
require 'egison'

include Egison

p(match_all([1,2,3,4,5]) do with(List.(*_, _x, *_, _y, *_)) { [x, y] } end)
#=> [[1, 2], [1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5]]

p(match_all([1,2,3,4,5]) do with(List.(*_, _x, *_, _y, *_, _z, *_)) { [x, y, z] } end)
#=> [[1, 2, 3], [1, 2, 4], [1, 2, 5], [1, 3, 4], [1, 3, 5], [1, 4, 5], [2, 3, 4], [2, 3, 5], [2, 4, 5], [3, 4, 5]]

```

### Poker Hands

We can write patterns for all poker-hands in one single pattern.
It is as follow.
Isn't it exciting?

```Ruby
require 'egison'

include Egison

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

### Twin Primes and Prime Triplets

The following code enumerates all twin primes with pattern-matching!
I believe it is also a really exciting demonstration.

```Ruby
require 'egison'
require 'prime'

include Egison

twin_primes = match_stream(Prime) {
  with(List.(*_, _p, __("p + 2"), *_)) {
    [p, p + 2]
  }
}

p twin_primes.take(10)
#=>[[3, 5], [5, 7], [11, 13], [17, 19], [29, 31], [41, 43], [59, 61], [71, 73], [101, 103], [107, 109]]
```

We can also enumerate prime triplets using **and-patterns** and **or-patterns** effectively.

```Ruby
prime_triplets = match_stream(Prime) {
  with(List.(*_, _p, And(Or(__("p + 2"), __("p + 4")), _m), __("p + 6"), *_)) {
    [p, m, p + 6]
  }
}

p prime_triplets.take(10)
#=>[[5, 7, 11], [7, 11, 13], [11, 13, 17], [13, 17, 19], [17, 19, 23], [37, 41, 43], [41, 43, 47], [67, 71, 73], [97, 101, 103], [101, 103, 107]]
```

### Algebraic Data Types

We can also patten match against algebraic data types as ordinary functional programming languages.
Here is a simple example.
Note that, the object in the pattern matches if the target object is equal with it.

```Ruby
class User < Struct.new(:name, :gender, :married, :doctor, :professor)
  def greet
    match(self) do
      with(User.(_name,       _,    _,    _, true)) { "Hello, Prof. #{name}!" }
      with(User.(_name,       _,    _, true,    _)) { "Hello, Dr. #{name}!" }
      with(User.(_name, :female, true,    _,    _)) { "Hello, Mrs. #{name}!" }
      with(User.(_name, :female,    _,    _,    _)) { "Hello, Ms. #{name}!" }
      with(User.(_name,   :male,    _,    _,    _)) { "Hello, Mr. #{name}!" }
      with(User.(_name,       _,    _,    _,    _)) { "Hello, #{name}!" }
    end
  end
end

u1 = User.new("Egi", :male, true, false, false)
p(u1.greet)#=>"Hello, Mr. Egi!"

u2 = User.new("Nanaka", :girl, false, false, false)
p(u2.greet)#=>"Hello, Nanaka!"

u3 = User.new("Hirai", :male, true, true, false)
p(u3.greet)#=>"Hello, Dr. Hirai!"

u4 = User.new("Hagiya", :male, true, true, true)
p(u4.greet)#=>"Hello, Prof. Hagiya!"
```

You can find more demonstrations in the [`sample`](https://github.com/egison/egison-ruby/tree/master/sample) directory.

## About Egison

If you get to love the above pattern-matching, please try [the Egison programming language](https://github.com/egison/egison), too.
Egison is the pattern-matching oriented, purely functional programming language.
Actually, the original pattern-matching system of Egison is more powerful.
For example, we can do following things in the original Egison.

- We can define new pattern-constructors.
- We can modularize useful patterns.

There is a new programming world!

## Contact

If you get interested in this Gem, please contact <a target="_blank" href="http://www.egison.org/~egi/">Satoshi Egi</a> or tweet to <a target="_blank" href="https://twitter.com/Egison_Lang">@Egison_Lang</a>.

We will talk about this gem in <a target="_blank" href="http://rubykaigi.org/2014">RubyKaigi 2014</a>!

## LICENSE

The license of this library code is BSD.
I learned how to extend Ruby and how to write a gem from the code of  <a target="_blank" href="https://github.com/k-tsj/pattern-match">the pattern-match gem</a> by Kazuki Tsujimoto.
I designed syntax of pattern-matching to go with that gem.
This library contains the copy from that gem.
The full license text is [here](https://github.com/egisatoshi/egison-ruby/blob/master/LICENSE).
