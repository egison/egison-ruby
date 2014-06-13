module Egison
  class LazyArray
    include Enumerable

    class OrgEnum
      def initialize(org_enum)
        # det_infinite(org_enum)
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

      def infinite?
        @is_infinite
      end

      def size
        return @cache.size if @terminated
        return Float::INFINITY if infinite?
        nil
      end

      private
      # def det_infinite(org_enum)
      #   return true if defined?(@is_infinite) && @is_infinite
      #   @is_infinite = if org_enum.respond_to?(:size)
      #     # org_enum.size.to_f.infinite?
      #     if org_enum.size.nil?
      #       nil
      #     else
      #       !org_enum.size.to_f.finite?
      #     end
      #   else
      #     nil
      #   end
      # end
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
      @terminated ? @cache.size : @org_enum.size
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

    # def to_a(recursive=nil)
    #   return super() unless recursive
    #   # return self if recursive == :if_finite && size.to_f.finite?
    #   map do |el|
    #     el.kind_of?(self.class) ? el.to_a(:if_finite) : el
    #   end
    # end

    def inspect
      "\#<#{self.class.name}#{@terminated ? @cache.inspect : "[#{@cache.join(', ')}...]"}>"
    end
  end
end

class ::Array
  alias :org_plus_meth_esc_by_egison_lazyarray :+
  def + other
    if other.kind_of?(Egison::LazyArray)
      return other.clone.unshift(*self)
    end
    org_plus_meth_esc_by_egison_lazyarray(other)
  end
end