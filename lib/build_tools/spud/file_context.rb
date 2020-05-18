require_relative 'rule'

module Spud::BuildTools
  module SpudBuild
    class FileContext
      attr_reader :rules

      def initialize(spud, filename)
        @spud = spud
        @filename = filename
        @rules = {}
      end

      def rule(name, *args, &block)
        files = args.select { |arg| arg.is_a?(String) }
        deps = args.select { |arg| arg.is_a?(Hash) }.reduce({}) { |hash, dep| hash.merge(dep) }

        name = prefix_rule(name)
        @rules[name] = Rule.new(@spud, self, @filename, name, files, deps, block)
      end

      def method_missing(name, *args, &block)
        rule(name, *args, &block)
      end

      def prefix_rule(name)
        "#{prefix}#{name}"
      end

      def prefix
        @prefix ||= @filename == 'Spudfile' ? '' : "#{File.basename(@filename, '.rb')}."
      end
    end
  end
end
