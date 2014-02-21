require 'egison/core'

class List
end

class Class
  include PatternMatch::Deconstructable

  def deconstruct(val)
    raise NotImplementedError, "need to define `#{__method__}'"
  end

  private

  def accept_self_instance_only(val)
    raise PatternMatch::PatternNotMatch unless val.kind_of?(self)
  end
end

class << Array
  def deconstruct(val)
    accept_self_instance_only(val)
    val
  end
end

class << List
  def deconstruct(val)
    accept_self_instance_only(val)
    val
  end
end
