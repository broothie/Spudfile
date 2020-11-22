# typed: strict
require 'sorbet-runtime'

module Spud
  class TaskArg
    extend T::Sig

    sig {returns(String)}
    attr_reader :name

    sig {returns(String)}
    attr_reader :type

    sig {returns(T.nilable(String))}
    attr_reader :default

    sig {params(name: String, type: String, default: T.nilable(String)).void}
    def initialize(name, type, default: nil)
      raise 'must be of type "ordered" or "named"' unless %w[ordered named].include?(type)

      @name = name
      @type = type
      @default = default
    end

    sig {returns(T::Boolean)}
    def required?
      !has_default?
    end

    sig {returns(T::Boolean)}
    def has_default?
      !!@default
    end

    sig {returns(T::Boolean)}
    def ordered?
      @type == 'ordered'
    end

    sig {returns(T::Boolean)}
    def named?
      @type == 'named'
    end

    sig {returns(String)}
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
