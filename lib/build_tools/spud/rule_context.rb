require_relative 'shell_error'
require_relative '../../shell'
require_relative '../../error'

module Spud::BuildTools
  module SpudBuild
    class RuleContext
      def initialize(spud, file_context)
        @__spud = spud

        file_context.singleton_methods.each do |method_name|
          define_singleton_method(method_name, &file_context.method(method_name))
        end
      end

      def __shell(cmd, silent: false)
        @__spud.watch_process = Spud::Shell.(cmd, silent: silent, wait: @__spud.wait?)
      end

      def sh(cmd)
        out = sh?(cmd)
        raise ShellError, cmd unless out.status.exitstatus.zero?

        out
      end

      def sh?(cmd)
        puts cmd
        __shell(cmd)
      end

      def shh(cmd)
        out = shh?(cmd)
        raise ShellError, cmd unless out.status.exitstatus.zero?

        out
      end

      def shh?(cmd)
        __shell(cmd)
      end

      def shhh(cmd)
        out = shhh?(cmd)
        raise ShellError, cmd unless out.status.exitstatus.zero?

        out
      end

      def shhh?(cmd)
        __shell(cmd, silent: true)
      end

      def invoke(name, *args, **kwargs)
        @__spud.invoke(name, *args, **kwargs)
      end
    end
  end
end
