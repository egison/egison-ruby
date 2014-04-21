require 'egison/core'

class Class
  include PatternMatch::Matchable

  def uncons(val)
    raise NotImplementedError, "need to define `#{__method__}'"
  end

  private

  def accept_array_only(val)
    raise PatternMatch::PatternNotMatch unless val.kind_of?(Array)
  end
end

class List
end

class << List
  def uncons(val)
    accept_array_only(val)
    x = val.shift
    [x, val]
  end
end
