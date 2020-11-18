module Spud
  class TaskArg
    # @param name [String]
    # @param type [String]
    # @param default [String]
    def initialize(name, type, default: nil)
      raise 'must be of type "positional" or "named"' unless %w[positional named].include?(type)

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
    def positional?
      @type == 'positional'
    end

    # @return [Boolean]
    def named?
      @type == 'named'
    end

    # @return [String]
    def to_s
      if positional?
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
