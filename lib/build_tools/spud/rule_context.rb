require_relative 'shell_error'
require_relative '../../shell'
require_relative '../../error'

module Spud::BuildTools
  module SpudBuild
    class RuleContext
      attr_reader :__process

      def initialize(spud, file_context)
        @__spud = spud
        @__process = nil

        file_context.singleton_methods.each do |method_name|
          define_singleton_method(method_name, &file_context.method(method_name))
        end
      end

      def sh(cmd)
        out = sh?(cmd)
        raise ShellError unless out.status.exitstatus.zero?

        out
      end

      def sh?(cmd)
        puts cmd
        Spud::Shell.new(cmd)
      end

      def shh(cmd)
        out = shh?(cmd)
        raise ShellError unless out.status.exitstatus.zero?

        out
      end

      def shh?(cmd)
        Spud::Shell.new(cmd)
      end

      def shhh(cmd)
        out = shhh?(cmd)
        raise ShellError, out unless out.status.exitstatus.zero?

        out
      end

      def shhh?(cmd)
        Spud::Shell.new(cmd, silent: true)
      end

      def invoke(name, *args, **kwargs)
        @__spud.invoke(name, *args, **kwargs)
      end
    end
  end
end
