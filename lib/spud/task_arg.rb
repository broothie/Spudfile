module Spud
  class TaskArg
    # @param name [String]
    # @param type [String]
    # @param default [String]
    def initialize(name, type, default: nil)
      raise 'must be of type "ordered" or "named"' unless %w[ordered named].include?(type)

      @name = name
      @type = type
      @default = default
    end

    # @return [Boolean]
    def required?
      !has_default?
    end

    # @return [Boolean]
    def has_default?
      !!@default
    end

    # @return [Boolean]
    def ordered?
      @type == 'ordered'
    end

    # @return [Boolean]
    def named?
      @type == 'named'
    end

    # @return [String]
    def to_s
      if ordered?
        if has_default?
          "<#{@name}=#{@default}>"
        else
          "<#{@name}>"
        end
      else
        if has_default?
          "--#{@name}=#{@default}"
        else
          "--#{@name}"
        end
      end
    end
  end
end
