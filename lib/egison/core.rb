require 'egison/version'
require 'egison/lazyarray'

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
      until @states.empty? do
        process
      end
      @results
    end

    def process
      state = @states.shift
      rets = state.process
      new_states = []
      rets.each do |ret|
        if ret.atoms.empty?
          @results += [ret.bindings]
        else
          new_states += [ret]
        end
      end
      @states = new_states + @states
    end
  end

  class MatchingStateStream
    def initialize(pat, tgt)
      @state = MatchingState.new(pat, tgt)
      @processes = []
    end

    def match(&block)
      @processes << Egison::LazyArray.new(@state.process_stream)
      until @processes.empty?
        process(@processes.shift, &block)
      end
    end

    def process(process_iter, &block)
      unless process_iter.empty?
        ret = process_iter.shift
        if ret.atoms.empty?
          block.(ret.bindings)
        else
          @processes << Egison::LazyArray.new(ret.process_stream)
        end
        @processes << process_iter
      end
    end
  end

  class MatchingState
    attr_accessor :atoms, :bindings

    def initialize(pat, tgt)
      @atoms = [[pat, tgt]]
      @bindings = []
    end

    def process
      atom = @atoms.shift
      rets = atom.first.match(atom.last, @bindings)
      rets.map do |new_atoms, new_bindings|
        new_state = clone
        new_state.atoms = new_atoms + new_state.atoms
        new_state.bindings += new_bindings
        new_state
      end
    end

    def process_stream(&block)
      return to_enum :process_stream unless block_given?
      atom = @atoms.shift
      atom.first.match_stream(atom.last, @bindings) do |new_atoms, new_bindings|
        new_state = clone
        new_state.atoms = new_atoms + new_state.atoms
        new_state.bindings += new_bindings
        block.(new_state)
      end
    end
  end

  class Pattern
    attr_accessor :quantified

    def initialize
    end

    def match(tgt, bindings)
    end

    def match_stream(tgt, bindings, &block)
      match(tgt, bindings).each(&block)
    end

    def to_a
      [PatternCollection.new(self)]
    end
  end

  class PatternElement < Pattern
    def initialize
      super()
      @quantified = false
    end
  end

  class PatternWithMatcher < PatternElement
    attr_reader :matcher, :subpatterns

    def initialize(matcher, *subpatterns)
      super()
      @matcher = matcher
      @subpatterns = subpatterns
    end

    def match(tgt, bindings)
      tgt = tgt.to_a
      if subpatterns.empty?
        unnileds = @matcher.unnil(tgt)
        unnileds.map do
          [[], []]
        end
      else
        subpatterns = @subpatterns.clone
        px = subpatterns.shift
        if px.kind_of?(Pattern)
          if px.quantified
            if subpatterns.empty?
              [[[[px.pattern, tgt]], []]]
            else
              unjoineds = @matcher.unjoin(tgt)
              unjoineds.map do |xs, ys|
                [[[px.pattern, xs], [PatternWithMatcher.new(@matcher, *subpatterns), ys]], []]
              end
            end
          else
            if tgt.empty?
              []
            else
              unconseds = @matcher.uncons(tgt)
              unconseds.map do |x, xs|
                [[[px, x], [PatternWithMatcher.new(@matcher, *subpatterns), xs]], []]
              end
            end
          end
        else
          if tgt.empty?
            []
          else
            unconseds = @matcher.uncons(tgt).select { |x, xs| px == x }
            unconseds.map do |x, xs|
              [[[PatternWithMatcher.new(@matcher, *subpatterns), xs]], []]
            end
          end
        end
      end
    end

    def match_stream(tgt, bindings, &block)
      if subpatterns.empty?
        if tgt.empty?
          return block.([[], []])
        end
      else
        subpatterns = @subpatterns.clone
        px = subpatterns.shift
        if px.kind_of?(Pattern)
          if px.quantified
            if subpatterns.empty?
              block.([[[px.pattern, tgt]], []])
            else
              @matcher.unjoin_stream(tgt) do |xs, ys|
                block.([[px.pattern, xs], [PatternWithMatcher.new(@matcher, *subpatterns), ys]], [])
              end
            end
          else
            unless tgt.empty?
              @matcher.uncons_stream(tgt) do |x, xs|
                block.([[px, x], [PatternWithMatcher.new(@matcher, *subpatterns), xs]], [])
              end
            end
          end
        else
          unless tgt.empty?
            @matcher.uncons_stream(tgt) do |x, xs|
              if px == x
                block.([[PatternWithMatcher.new(@matcher, *subpatterns), xs]], [])
              end
            end
          end
        end
      end
    end
  end

  class OrPattern < PatternElement
    attr_reader :pats

    def initialize(*subpatterns)
      super()
      @pats = subpatterns
    end

    def match(tgt, bindings)
      @pats.map { |pat| [[[pat, tgt]], []] }
    end
  end
  
  class AndPattern < PatternElement
    attr_reader :pats

    def initialize(*subpatterns)
      super()
      @pats = subpatterns
    end

    def match(tgt, bindings)
      [[@pats.map { |pat| [pat, tgt] }, []]]
    end
  end
  
  class Wildcard < PatternElement
    def initialize()
      super()
    end

    def match(tgt, bindings)
      [[[], []]]
    end
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
      if val.__send__(:===, tgt)
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
      m = obj.singleton_class.ancestors.find { |i| i.kind_of?(BindingModule) }
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
    attr_accessor :pattern

    def initialize(pat)
      super()
      @quantified = true
      @pattern = pat
    end
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

    def _(*vals)
      case vals.length
      when 0
        uscore = Wildcard.new()
        class << uscore
          def [](*args)
            Egison::List.call(*args)
          end
        end
        uscore
      else
        undefined
      end
    end

    def __(*vals)
      case vals.length
      when 0
        Wildcard.new()
      when 1
        ValuePattern.new(@ctx, vals[0])
      else
        undefined
      end
    end

    def ___(*vals)
      case vals.length
      when 0
        Wildcard.new()
      else
        undefined
      end
    end

    def Or(*subpatterns)
      OrPattern.new(*subpatterns)
    end

    def And(*subpatterns)
      AndPattern.new(*subpatterns)
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
      m = obj.singleton_class.ancestors.find { |i| i.kind_of?(BindingModule) }
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

  class Env2 < Env
    def with(pat, &block)
      ctx = @ctx
      tgt = @tgt
      if pat.kind_of?(Pattern)
        mstack = MatchingStateStack.new(pat,tgt)
        mstack.match
        if mstack.results.empty?
          nil
        else
          ret = with_bindings(ctx, mstack.results.first, &block)
          ::Kernel.throw(:exit_match, ret)
        end
      else
        if pat == tgt
          ret = with_bindings(ctx, [], &block)
          ::Kernel.throw(:exit_match, ret)
        else
          nil
        end
      end
    rescue PatternNotMatch
    end
  end

  class EnvE < Env
    def with(pat, &block)
      ctx = @ctx
      tgt = @tgt
      mstack = MatchingStateStream.new(pat,tgt)
      ::Egison::LazyArray.new(::Enumerator.new{|y|
        mstack.match do |bindings|
          y << with_bindings(ctx, bindings, &block)
        end
      })
    rescue PatternNotMatch
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
    private_constant :Env, :Env2, :EnvE
  end
end

module Egison
  extend self

  def match_all(tgt, &block)
    env = PatternMatch.const_get(:Env).new(self, tgt)
    env.instance_eval(&block)
  end

  def match_stream(tgt, &block)
    if !(tgt.kind_of?(Array) || tgt.kind_of?(Egison::LazyArray))
      tgt = Egison::LazyArray.new(tgt)
    end
    env = PatternMatch.const_get(:EnvE).new(self, tgt)
    env.instance_eval(&block)
  end

  def match(tgt, &block)
    env = PatternMatch.const_get(:Env2).new(self, tgt)
    catch(:exit_match) do
      env.instance_eval(&block)
    end
  end

  alias match_single match
end
