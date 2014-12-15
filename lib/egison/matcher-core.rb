require 'egison/core'
require 'egison/lazyarray'
module Egison
  extend self

  module PatternConstructorBase
    include PatternMatch::Matchable

    def sep(val)
      val2 = val.clone
      [val2.shift, val2]
    end

    def sep!(val)
      [val.shift, val.clone]
    end

    def cln_emp_cln(val)
      [val.clone, [], val.clone]
    end

    def unnil(val)
      if val.empty?
        [[]]
      else
        []
      end
    end

    def uncons(val)
      fail NotImplementedError, "need to define `#{__method__}'"
    end

    def uncons_stream(val, &block)
      fail NotImplementedError, "need to define `#{__method__}'"
    end

    private
      def test_conv_lazy_array!(val)
        fail PatternMatch::PatternNotMatch unless val.respond_to?(:each)
        val = Egison::LazyArray.new(val) unless val.is_a?(EgisonArray)
      end
  end

  class << Struct
    include PatternConstructorBase

    def unnil(val)
      [[]]
    end

    def uncons(val)
      [sep(val)]
    end

    def unjoin(val)
      val2, xs, ys = cln_emp_cln(val)
      rets = [[xs, ys]]
      until val2.empty?
        x, ys = sep!(val2)
        xs += [x]
        rets += [[xs, ys]]
      end
      rets
    end
  end

  class List
  end

  class << List
    include PatternConstructorBase

    def uncons(val)
      [sep(val)]
    end

    def uncons_stream(val, &block)
      test_conv_lazy_array!(val)
      block.(sep(val))
    end

    def unjoin(val)
      val2, xs, ys = cln_emp_cln(val)
      rets = [[xs, ys]]
      until val2.empty?
        x, ys = sep!(val2)
        xs += [x]
        rets += [[xs, ys]]
      end
      rets
    end

    def unjoin_stream(val, &block)
      test_conv_lazy_array!(val)
      val2, xs, ys = cln_emp_cln(val)
      block.([xs, ys])
      until val2.empty?
        x, ys = sep!(val2)
        xs += [x]
        block.([xs, ys])
      end
    end
  end
end
