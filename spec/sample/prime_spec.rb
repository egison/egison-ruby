require 'spec_helper'
require 'egison'
require 'prime'

include Egison

def twin_primes
  match_stream(Prime) {
    with(List.(*_, _x, __("x + 2"), *_)) {
      [x, x + 2]
    }
  }
end

describe "sample" do
  describe "prime.rb" do

    it %q{twin_primes.take(10)} do
      expect(twin_primes.take(10)).to eq \
        [[3, 5], [5, 7], [11, 13], [17, 19], [29, 31], [41, 43], [59, 61], [71, 73], [101, 103], [107, 109]]
    end

    # assign to a variable, execute twice (or more), then obtain the same results. (for twin-primes)
    it %q{assign to a variable, execute twice (or more), then obtain the same results. (for twin-primes)} do
      tp = twin_primes
      tp.take(10) # discard
      expect(tp.take(10)).to eq \
        [[3, 5], [5, 7], [11, 13], [17, 19], [29, 31], [41, 43], [59, 61], [71, 73], [101, 103], [107, 109]]
    end
  end
end
