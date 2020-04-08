require_relative 'rule'

module Spud::BuildTools
  module SpudBuild
    class FileContext
      attr_reader :rules

      def initialize(spud)
        @spud = spud
        @rules = {}
      end

      def rule(name, *args, &block)
        name = name.to_s
        files = args.select { |arg| arg.is_a?(String) }
        deps = args.select { |arg| arg.is_a?(Hash) }.reduce({}) { |hash, dep| hash.merge(dep) }
        @rules[name] = Rule.new(@spud, self, name, files, deps, block)
      end

      def method_missing(method_name, *args, &block)
        method_name = method_name.to_s
        rule(method_name, *args, &block)
      end
    end
  end
end
