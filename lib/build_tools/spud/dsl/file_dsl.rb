require_relative '../rule'

module Spud::BuildTools
  module SpudBuild
    class FileDsl
      attr_reader :__rules

      def initialize(spud, filename)
        @__spud = spud
        @__filename = filename
        @__rules = {}
      end

      def require_relative(name)
        require("./#{name}")
      end

      def rule(name, *files, **deps, &block)
        prefix = @__filename == 'Spudfile' ? '' : "#{File.basename(@__filename, '.rb')}."
        name = "#{prefix}#{name}"

        @__rules[name] = Rule.new(@__spud, self, @__filename, name, files, deps, block)
      end

      def method_missing(name, *files, **deps, &block)
        rule(name, *files, **deps, &block)
      end
    end
  end
end
