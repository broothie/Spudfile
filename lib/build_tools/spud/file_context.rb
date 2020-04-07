require_relative 'rule'

module Spud::BuildTools
  module SpudBuild
    class FileContext
      attr_reader :rules

      def initialize(spud)
        @spud = spud
        @rules = {}
      end

      def rule(name, deps = {}, &block)
        name = name.to_s
        @rules[name] = Rule.new(@spud, self, name, deps, &block)
      end

      def method_missing(method_name, *args, &block)
        rule(method_name, *args, &block)
      end
    end
  end
end
