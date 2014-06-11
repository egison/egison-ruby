require 'egison/version'
# require 'continuation'

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

  class LazyArray
    include Enumerable

    class OrgEnum
      def initialize(org_enum)
        if org_enum.kind_of?(::Array)
          # @org_enum = org_enum
          @cache = org_enum
          @index = -1
          @terminated = true
        else
          @org_enum = org_enum.to_enum
          @cache = []
          @index = -1
          @terminated = false
        end
      end

      def next
        index = @index += 1
        return @cache[index] if @cache.size > index
        raise StopIteration('iteration reached an end') if @terminated
        el = @org_enum.next
        @cache << el
        el
      rescue StopIteration => ex
        @index -= 1
        @terminated = true
        raise ex
      end

      def rewind(index=0)
        @index = index - 1
      end
    end

    def initialize(org_enum)
      @org_enum = OrgEnum.new(org_enum)
      @cache = []
      @terminated = false
    end

    def each(&block)
      return to_enum unless block_given?
      @cache.each(&block)
      return if @terminated
      while true  # StopIteration will NOT be raised if `loop do ... end`
        el = @org_enum.next
        @cache.push(el)
        block.(el)
      end
    rescue StopIteration => ex
      @terminated = true
    end

    def shift
      if @cache.size > 0
        @cache.shift
      elsif @terminated
        nil
      else
        begin
          @org_enum.next
        rescue StopIteration => ex
          @terminated = true
          nil
        end
      end
    end

    def unshift(*obj)
      @cache.unshift(*obj)
      self
    end

    def empty?
      # @terminated && @cache.empty?
      return false unless @cache.empty?
      return true if @terminated
      begin
        @cache << @org_enum.next
        false
      rescue StopIteration => ex
        @terminated = true
        true
      end
    end

    def size
      @terminated ? @cache.size : nil
    end
    alias :length :size

    def clone
      obj = super
      obj.instance_eval{
        @org_enum = @org_enum.clone
        @cache = @cache.clone
      }
      obj
    end
    alias :dup :clone

    def inspect
      "\#<#{self.class.name}:#{self.object_id}#{@terminated ? @cache.inspect : "[#{@cache.join(', ')}...]"}>"
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
    attr_accessor :states

    def initialize(pat, tgt)
      @states = [MatchingState.new(pat, tgt)]
    end

    def match(&block)
      return to_enum :match unless block_given?
      until @states.empty? do
        process(&block)
      end
      self
    end

    def process(state=nil, &block)
      state ||= @states.shift
      # new_states = []
      state.process_stream do |ret|
        if ret.atoms.empty?
          block.(ret.bindings)
        else
          # new_states += [ret]
          process(ret, &block)
        end
      end
      # @states = new_states + @states
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
      if subpatterns.empty?
        if tgt.empty?
          return [[[], []]]
        else
          return []
        end
      else
        subpatterns = @subpatterns.clone
        px = subpatterns.shift
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
      end
    end
  end

  class Wildcard < PatternElement
    def initialize()
      super()
    end

    def match(tgt, bindings)
      [[[], []]]
    end

    def match_stream(tgt, bindings, &block)
      block.([[], []])
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

    def match_stream(tgt, bindings, &block)
      block.([[], [[name, tgt]]])
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

    def match_stream(tgt, bindings, &block)
      val = with_bindings(@ctx, bindings, {:expr => @expr}) { eval expr }
      if val.__send__(:===, tgt)
        block.([[], []])
      # else
      #   []
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
        ValuePattern.new(@ctx, name.to_s.gsub(/^__/, "").gsub("_plus_", "+").gsub("_minus_", "-"))
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
            List.call(*args)
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
      mstack = MatchingStateStack.new(pat,tgt)
      mstack.match
      if mstack.results.empty?
        nil
      else
        ret = with_bindings(ctx, mstack.results.first, &block)
        ::Kernel.throw(:exit_match, ret)
      end
    rescue PatternNotMatch
    end
  end

  class EnvE < Env
    def with(pat, &block)
      ctx = @ctx
      tgt = @tgt
      mstack = MatchingStateStream.new(pat,tgt)
      ::Enumerator.new do |y|
        mstack.match do |bindings|
          y << with_bindings(ctx, bindings, &block)
        end
      end
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

module Kernel
  private

  def match_all(tgt, &block)
    env = PatternMatch.const_get(:Env).new(self, tgt)
    env.instance_eval(&block)
  end

  def match_stream(tgt, &block)
    if !(tgt.kind_of?(Array) || tgt.kind_of?(PatternMatch::LazyArray))
      tgt = PatternMatch::LazyArray.new(tgt)
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
