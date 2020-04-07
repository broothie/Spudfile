require_relative 'file_context'
require_relative 'rule_context'
require_relative '../build_rule'
require_relative '../../error'

module Spud::BuildTools
  module SpudBuild
    class Rule < BuildRule
      def initialize(spud, file_context, name, deps = {}, &block)
        @spud = spud
        @file_context = file_context
        @name = name
        @deps = deps
        @block = block
      end

      def invoke(*args, **kwargs)
        missing = required_params.length - args.length
        if missing > 0
          names = required_params.map { |name| "'#{name}'" }.join(', ')
          arguments = missing > 1 ? 'arguments' : 'argument'
          raise Spud::Error, "invocation of '#{@name}' missing required #{arguments} #{names}"
        end

        if key_params?
          begin
            RuleContext.new(@spud, @file_context).instance_exec(*args, **kwargs, &@block)
          rescue ArgumentError => e
            raise Spud::Error, "invocation of '#{@name}' with #{e.message}"
          end
        else
          RuleContext.new(@spud, @file_context).instance_exec(*args, &@block)
        end
      end

      private

      def key_params?
        lam.parameters.map(&:first).include?(:key)
      end

      def required_params
        lam.parameters.select { |p| p.first == :req }.map(&:last)
      end

      def lam
        @lam ||= build_lam
      end

      def build_lam
        line = @block.source_location.last - 1
        line = File.read(filename).split("\n")[line]

        match = /(do|{)\s*\|(?<params>[^|]+)\|/.match(line)
        return -> {} unless match

        param_source = match[:params]
        eval("-> (#{param_source}) {}")
      end

      def filename
        'Spudfile'
      end
    end
  end
end
