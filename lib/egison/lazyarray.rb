module Egison
  class LazyArray
    include Enumerable

    class OrgEnum
      def initialize(org_enum)
        @src_enums = []
        if org_enum.kind_of?(::Array)
          @org_enum = [].to_enum  # DUMMY
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
        raise StopIteration.new('iteration reached an end') if @terminated
        el = org_enum_next
        @cache << el
        el
      rescue StopIteration => ex
        @index -= 1
        raise ex
      end

      def rewind(index=0)
        @index = index - 1
      end

      def clone
        obj = super
        obj.instance_eval do
          @src_enums = @src_enums.clone
        end
        obj
      end

      def concat other
        if @terminated && other.kind_of?(::Array)
          @cache.concat(other)
        else
          @src_enums.push(other)
          @terminated = false
        end
        self
      end

      private
      def org_enum_next
        el = nil
        while el.nil?
          begin
            el = @org_enum.next
          rescue StopIteration => ex
            if @src_enums.empty?
              @terminated = true
              raise ex
            end
            @org_enum = @src_enums.shift.to_enum
            @cache = @cache.clone
          end
        end
        el
      end
    end

    private_constant :OrgEnum if respond_to?(:private_constant)

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
      obj.instance_eval do
        @org_enum = @org_enum.clone
        @cache = @cache.clone
      end
      obj
    end
    alias :dup :clone

    def concat other
      @org_enum.concat(other)
      @terminated = false
      self
    end

    def + other
      clone.concat(other)
    end

    def inspect
      "\#<#{self.class.name}#{@terminated ? @cache.inspect : "[#{@cache.map(&:inspect).join(', ')}...]"}>"
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