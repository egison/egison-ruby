module Egison
  class LazyArray
    include Enumerable

    class OrgEnum
      def initialize(org_enum)
        # det_infinite(org_enum)
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

      # def infinite?
      #   @is_infinite
      # end

      # def size
      #   return @cache.size if @terminated
      #   return Float::INFINITY if infinite?
      #   nil
      # end

      def clone
        obj = super
        obj.instance_eval {
          @src_enums = @src_enums.clone
        }
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
          rescue LocalJumpError => err
            p @org_enum
            p err
            p err.reason
            # p err.exit_value
          end
        end
        el
      end
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

    def concat other
      @org_enum.concat(other)
      @terminated = false
      self
    end

    def + other
      clone.concat(other)
    end

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