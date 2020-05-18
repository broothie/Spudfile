require_relative 'shell_error'
require_relative '../../shell'
require_relative '../../error'

module Spud::BuildTools
  module SpudBuild
    class RuleContext
      def initialize(spud, file_context)
        @spud = spud

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

        out = Spud::Shell.cmd(cmd)
        puts out unless out.empty?

        out
      end

      def shh(cmd)
        out = shh?(cmd)
        raise ShellError unless out.status.exitstatus.zero?

        out
      end

      def shh?(cmd)
        out = Spud::Shell.cmd(cmd)
        puts out unless out.empty?

        out
      end

      def shhh(cmd)
        out = shhh?(cmd)
        raise ShellError, out unless out.status.exitstatus.zero?

        out
      end

      def shhh?(cmd)
        Spud::Shell.cmd(cmd)
      end

      def invoke(name, *args, **kwargs)
        @spud.invoke(name, *args, **kwargs)
      end
    end
  end
end
