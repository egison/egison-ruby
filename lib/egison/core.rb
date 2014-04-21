require 'egison/version'
require 'continuation'

module PatternMatch

  class Pattern
    attr_reader :bindings

    def initialize()
      @bindings = Hash.new
    end

    def match(tgt)
    end

    def bind(name, val)
      @bindings[name] = val
    end
  end

  class PatternElement < Pattern
  end

  class PatternVariable < PatternElement
    attr_reader :name

    def initialize(name)
      super()
      @name = name
    end

    def match(tgt)
      bind(name, tgt)
      true
    end

  end

  class PatternCollection < Pattern
  end

  class Env < BasicObject
    def initialize(ctx, tgt)
      @ctx = ctx
      @tgt = tgt
    end

    private

    def with(pat, &block)
      ctx = @ctx
      tgt = @tgt
      if pat.match(tgt)
        ret = with_bindings(ctx, pat.bindings, &block)
      else
        nil
      end
    rescue PatternNotMatch
    end

    def method_missing(name, *args)
      ::Kernel.raise ::ArgumentError, "wrong number of arguments (#{args.length} for 0)" unless args.empty?
      if /^__/.match(name.to_s)
        PatternVariable.new(name.to_s.gsub(/^__/, "").to_sym)
      else
        undefined
      end
    end

    class BindingModule < ::Module
    end

    def with_bindings(obj, bindings, &block)
      binding_module(obj).module_eval do
        begin
          bindings.each do |name, val|
            define_method(name) { val }
            private name
          end
          obj.instance_eval(&block)
        ensure
          bindings.each do |name, _|
            remove_method(name)
          end
        end
      end
    end

    def binding_module(obj)
      m = obj.singleton_class.ancestors.find {|i| i.kind_of?(BindingModule) }
      unless m
        m = BindingModule.new do
          @stacks = ::Hash.new {|h, k| h[k] = [] }
        end
        obj.singleton_class.class_eval do
          if respond_to?(:prepend, true)
            prepend m
          else
            include m
          end
        end
      end
      m
    end
  end

  class PatternNotMatch < Exception; end
  class PatternMatchError < StandardError; end
  class NoMatchingPatternError < PatternMatchError; end
  class MalformedPatternError < PatternMatchError; end

  # Make Pattern and its subclasses/Env private.
  if respond_to?(:private_constant)
    constants.each do |c|
      klass = const_get(c)
      next unless klass.kind_of?(Class)
      if klass <= Pattern
        private_constant c
      end
    end
    private_constant :Env
  end
end

module Kernel
  private

  def match(tgt, &block)
    env = PatternMatch.const_get(:Env).new(self, tgt)
    env.instance_eval(&block)
  end
end
