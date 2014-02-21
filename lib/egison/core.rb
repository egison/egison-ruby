require 'egison/version'
require 'continuation'

module PatternMatch
  module Deconstructable
    def call(*subpatterns)
      pattern_matcher(*subpatterns)
    end
  end

  class ::Object
    private

    def pattern_matcher(*subpatterns)
      PatternObjectDeconstructor.new(self, *subpatterns)
    end
  end

  module HasOrderedSubPatterns
    private

    def set_subpatterns_relation
      super
      subpatterns.each_cons(2) do |a, b|
        a.next = b
        b.prev = a
      end
    end
  end

  class Pattern
    attr_accessor :parent, :next, :prev
    attr_reader :choice_points

    def initialize(*subpatterns)
      @parent = nil
      @next = nil
      @prev = nil
      @choice_points = []
      @subpatterns = subpatterns.map {|i| i.kind_of?(Pattern) ? i : PatternValue.new(i) }
      set_subpatterns_relation
    end

    def vars
      subpatterns.map(&:vars).flatten
    end

    def ancestors
      root? ? [self] : parent.ancestors.unshift(self)
    end

    def quasibinding
      vars.each_with_object({}) {|v, h| h[v.name] = v.val }
    end

    def to_a
      [self, PatternQuantifier.new(0, true)]
    end

    def quantifier?
      raise NotImplementedError
    end

    def quantified?
       directly_quantified? or (root? ? false : @parent.quantified?)
    end

    def directly_quantified?
      @next and @next.quantifier?
    end

    def root
      root? ? self : @parent.root
    end

    def root?
      @parent == nil
    end

    def validate
      subpatterns.each(&:validate)
    end

    def match(vals)
      if directly_quantified?
        q = @next
        repeating_match(vals, q.greedy?) do |vs, rest|
          if vs.length < q.min_k
            next false
          end
          vs.all? {|v| yield(v) } and q.match(rest)
        end
      else
        if vals.empty?
          return false
        end
        val, *rest = vals
        yield(val) and (@next ? @next.match(rest) : rest.empty?)
      end.tap do |matched|
        if root? and not matched and not choice_points.empty?
          restore_choice_point
        end
      end
    end

    def append(pattern)
      if @next
        @next.append(pattern)
      else
        if subpatterns.empty?
          if root?
            new_root = PatternAnd.new(self)
            self.parent = new_root
          end
          pattern.parent = @parent
          @next = pattern
        else
          subpatterns[-1].append(pattern)
        end
      end
    end

    def inspect
      "#<#{self.class.name}: subpatterns=#{subpatterns.inspect}>"
    end

    private

    attr_reader :subpatterns

    def repeating_match(vals, is_greedy)
      quantifier = @next
      candidates = generate_candidates(vals)
      (is_greedy ? candidates : candidates.reverse).each do |(vs, rest)|
        vars.each {|i| i.set_bind_to(quantifier) }
        begin
          cont = nil
          if callcc {|c| cont = c; yield vs, rest }
            save_choice_point(cont)
            return true
          end
        rescue PatternNotMatch
        end
        vars.each {|i| i.unset_bind_to(quantifier) }
      end
      false
    end

    def generate_candidates(vals)
      vals.length.downto(0).map do |n|
        [vals.take(n), vals.drop(n)]
      end
    end

    def save_choice_point(choice_point)
      root.choice_points.push(choice_point)
    end

    def restore_choice_point
      root.choice_points.pop.call(false)
    end

    def set_subpatterns_relation
      subpatterns.each do |i|
        i.parent = self
      end
    end
  end

  class PatternQuantifier < Pattern
    attr_reader :min_k

    def initialize(min_k, is_greedy)
      super()
      @min_k = min_k
      @is_greedy = is_greedy
    end

    def validate
      super
      raise MalformedPatternError unless @prev and ! @prev.quantifier?
      raise MalformedPatternError unless @parent.kind_of?(HasOrderedSubPatterns)
    end

    def quantifier?
      true
    end

    def match(vals)
      if @next
        @next.match(vals)
      else
        vals.empty?
      end
    end

    def greedy?
      @is_greedy
    end

    def inspect
      "#<#{self.class.name}: min_k=#{@min_k}, is_greedy=#{@is_greedy}>"
    end
  end

  class PatternElement < Pattern
    def quantifier?
      false
    end
  end

  class PatternDeconstructor < PatternElement
  end

  class PatternObjectDeconstructor < PatternDeconstructor
    include HasOrderedSubPatterns

    def initialize(deconstructor, *subpatterns)
      super(*subpatterns)
      @deconstructor = deconstructor
    end

    def match(vals)
      super do |val|
        deconstructed_vals = @deconstructor.deconstruct(val)
        if subpatterns.empty?
          next deconstructed_vals.empty?
        end
        subpatterns[0].match(deconstructed_vals)
      end
    end

    def inspect
      "#<#{self.class.name}: deconstructor=#{@deconstructor.inspect}, subpatterns=#{subpatterns.inspect}>"
    end
  end

  class PatternVariable < PatternElement
    attr_reader :name, :val

    def initialize(name)
      super()
      @name = name
      @val = nil
      @bind_to = nil
    end

    def match(vals)
      super do |val|
        bind(val)
        true
      end
    end

    def vars
      [self]
    end

    def set_bind_to(quantifier)
      n = nest_level(quantifier)
      if n == 0
        @val = @bind_to = []
      else
        outer = @val
        (n - 1).times do
          outer = outer[-1]
        end
        @bind_to = []
        outer << @bind_to
      end
    end

    def unset_bind_to(quantifier)
      n = nest_level(quantifier)
      @bind_to = nil
      if n == 0
        # do nothing
      else
        outer = @val
        (n - 1).times do
          outer = outer[-1]
        end
        outer.pop
      end
    end

    def inspect
      "#<#{self.class.name}: name=#{name.inspect}, val=#{@val.inspect}>"
    end

    private

    def bind(val)
      if quantified?
        @bind_to << val
      else
        @val = val
      end
    end

    def nest_level(quantifier)
      raise PatternMatchError unless quantifier.kind_of?(PatternQuantifier)
      qs = ancestors.map {|i| (i.next and i.next.quantifier?) ? i.next : nil }.compact.reverse
      qs.index(quantifier) || (raise PatternMatchError)
    end
  end

  class PatternValue < PatternElement
    def initialize(val, compare_by = :===)
      super()
      @val = val
      @compare_by = compare_by
    end

    def match(vals)
      super do |val|
        @val.__send__(@compare_by, val)
      end
    end

    def inspect
      "#<#{self.class.name}: val=#{@val.inspect}>"
    end
  end

  class Env < BasicObject
    def initialize(ctx, val)
      @ctx = ctx
      @val = val
    end

    private

    def with(pat_or_val, guard_proc = nil, &block)
      ctx = @ctx
      pat = pat_or_val.kind_of?(Pattern) ? pat_or_val : PatternValue.new(pat_or_val)
      pat.validate
      if pat.match([@val])
        ret = with_quasibinding(ctx, pat.quasibinding, &block)
        ::Kernel.throw(:exit_match, ret)
      else
        nil
      end
    rescue PatternNotMatch
    end

    def ___
      PatternQuantifier.new(0, true)
    end

    def method_missing(name, *args)
      ::Kernel.raise ::ArgumentError, "wrong number of arguments (#{args.length} for 0)" unless args.empty?
      case name.to_s
      when /\A__(\d+)(\??)\z/
        PatternQuantifier.new($1.to_i, $2.empty?)
      else
        PatternVariable.new(name)
      end
    end

    def _(*vals)
      case vals.length
      when 0
        uscore = PatternVariable.new(:_)
        class << uscore
          def [](*args)
            Array.call(*args)
          end

          def vars
            []
          end

          private

          def bind(val)
          end
        end
        uscore
      when 1
        PatternValue.new(vals[0])
      when 2
        PatternValue.new(vals[0], vals[1])
      else
        ::Kernel.raise MalformedPatternError
      end
    end

    alias __ _
    alias _l _

    def check_for_duplicate_vars(vars)
      vars.each_with_object({}) do |v, h|
        if h.has_key?(v.name)
          unless h[v.name] == v.val
            return false
          end
        else
          h[v.name] = v.val
        end
      end
      true
    end

    class QuasiBindingModule < ::Module
    end

    def with_quasibinding(obj, quasibinding, &block)
      quasibinding_module(obj).module_eval do
        begin
          quasibinding.each do |name, val|
            stack = @stacks[name]
            if stack.empty?
              define_method(name) { stack[-1] }
              private name
            end
            stack.push(val)
          end
          obj.instance_eval(&block)
        ensure
          quasibinding.each do |name, _|
            @stacks[name].pop
            if @stacks[name].empty?
              remove_method(name)
            end
          end
        end
      end
    end

    def quasibinding_module(obj)
      m = obj.singleton_class.ancestors.find {|i| i.kind_of?(QuasiBindingModule) }
      unless m
        m = QuasiBindingModule.new do
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

  def match(val, &block)
    do_match = Proc.new do |val|
      env = PatternMatch.const_get(:Env).new(self, val)
      catch(:exit_match) do
        env.instance_eval(&block)
        raise PatternMatch::NoMatchingPatternError
      end
    end
    do_match.(val)
  end
end
