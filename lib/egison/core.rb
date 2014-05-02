require 'egison/version'
require 'continuation'

module PatternMatch
  module Matchable
    def call(*subpatterns)
      pattern_matcher(*subpatterns)
    end
  end

  class ::Object
    private

    def pattern_matcher(*subpatterns)
      PatternWithMatcher.new(self, *subpatterns)
    end
  end

  class MatchingStateStack
    attr_accessor :states
    attr_accessor :results
    
    def initialize(pat, tgt)
      @states = [MatchingState.new(pat, tgt)]
      @results = []
    end

    def match
      while !@states.empty? do
        process
      end
      @results
    end
    
    def process
      state = pop
      new_states = state.process
      next_states = []
      new_states.each { |new_state|
        if new_state.atoms.empty? then
          @results = @results + [new_state.bindings]
        else
          next_states = next_states + [new_state]
        end
      }
      append(next_states)
    end

    def pop
      @states.shift
    end

    def push(pat,tgt)
      @states = [pat, tgt] + atoms
    end

    def append(new_states)
      @states = new_states + @states
    end
  end

  class MatchingState
    attr_accessor :atoms
    attr_accessor :bindings

    def initialize(pat, tgt)
      @atoms = [[pat, tgt]]
      @bindings = []
    end

    def process
      atom = pop
      rets = atom.first.match(atom.last, @bindings)
      rets.map { |new_atoms, new_bindings|
        new_state = self.clone
        new_state.append(new_atoms)
        new_state.append_bindings(new_bindings)
        new_state
      }
    end
    
    def pop
      @atoms.shift
    end

    def push(pat,tgt)
      @atoms = [pat, tgt] + @atoms
    end

    def append(new_atoms)
      @atoms = new_atoms + @atoms
    end

    def append_bindings(new_bindings)
      @bindings = @bindings + new_bindings
    end
  end

  class Pattern
    def initialize()
    end

    def match(tgt, bindings)
    end
  end

  class PatternWithMatcher < Pattern
    attr_reader :matcher, :subpatterns

    def initialize(matcher, *subpatterns)
      super()
      @matcher = matcher
      @subpatterns = subpatterns
    end

    def match(tgt, bindings)
      if subpatterns.empty? then
        if tgt.empty? then
          return [[[], []]]
        else
          return []
        end
      else
        unconseds = @matcher.uncons(tgt)
        px = subpatterns.shift
        unconseds.map { |x, xs|
          [[[px, x], [PatternWithMatcher.new(@matcher, *subpatterns), xs]], []]
        }
      end
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

    def match(tgt, bindings)
      [[[], [[name, tgt]]]]
    end
  end

  class ValuePattern < PatternElement
    def initialize(ctx, expr)
      super()
      @ctx = ctx
      @expr = expr
    end

    def match(tgt, bindings)
      val = with_bindings(@ctx, bindings, {:expr => @expr}) { eval expr }
      if val.__send__(:===, tgt) then
        [[[], []]]
      else
        []
      end
    end

    class BindingModule < ::Module
    end

    def with_bindings(obj, bindings, ext_bindings, &block)
      binding_module(obj).module_eval do
        begin
          bindings.each do |name, val|
            define_method(name) { val }
            private name
          end
          ext_bindings.each do |name, val|
            define_method(name) { val }
            private name
          end
          obj.instance_eval(&block)
        ensure
          bindings.each do |name, _|
            remove_method(name)
          end
          ext_bindings.each do |name, _|
            remove_method(name)
          end
        end
      end
    end

    def binding_module(obj)
      m = obj.singleton_class.ancestors.find {|i| i.kind_of?(BindingModule) }
      unless m
        m = BindingModule.new
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
      mstack = MatchingStateStack.new(pat,tgt)
      mstack.match
      mstack.results.map { |bindings|
        ret = with_bindings(ctx, bindings, &block)
      }
    rescue PatternNotMatch
    end

    def method_missing(name, *args)
      ::Kernel.raise ::ArgumentError, "wrong number of arguments (#{args.length} for 0)" unless args.empty?
      if /^__/.match(name.to_s)
        ValuePattern.new(@ctx, name.to_s.gsub(/^__/, ""))
      elsif /^_/.match(name.to_s)
        PatternVariable.new(name.to_s.gsub(/^_/, "").to_sym)
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
        m = BindingModule.new
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

  def match_all(tgt, &block)
    env = PatternMatch.const_get(:Env).new(self, tgt)
    env.instance_eval(&block)
  end

  def match(tgt, &block)
    env = PatternMatch.const_get(:Env).new(self, tgt)
    env.instance_eval(&block)
  end
end
