require_relative 'rule'

module Spud::BuildTools
  module SpudBuild
    class FileContext
      attr_reader :__rules

      def initialize(spud, filename)
        @__spud = spud
        @__filename = filename
        @__rules = {}
      end

      def require_relative(name)
        require(name)
      end

      def rule(name, *args, &block)
        files = args.select { |arg| arg.is_a?(String) }
        deps = args.select { |arg| arg.is_a?(Hash) }.reduce({}) { |hash, dep| hash.merge(dep) }

        prefix = @__filename == 'Spudfile' ? '' : "#{File.basename(@__filename, '.rb')}."
        name = "#{prefix}#{name}"

        @__rules[name] = Rule.new(@__spud, self, @__filename, name, files, deps, block)
      end

      def method_missing(name, *args, &block)
        rule(name, *args, &block)
      end
    end
  end
end
