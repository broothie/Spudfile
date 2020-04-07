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

      def sh(*args)
        out = sh?(*args)
        raise ShellError unless out.status.exitstatus.zero?
      end

      def sh?(*args)
        cmd = args.join(' ')
        puts cmd

        out = Spud::Shell.cmd(cmd)
        puts out

        out
      end

      def shh(*args)
        out = shh?(*args)
        raise ShellError unless out.status.exitstatus.zero?
      end

      def shh?(*args)
        out = Spud::Shell.cmd(args.join(' '))
        puts out

        out
      end

      def shhh(*args)
        out = shhh?(*args)
        raise ShellError, out unless out.status.exitstatus.zero?
      end

      def shhh?(*args)
        Spud::Shell.cmd(args.join(' '))
      end

      def invoke(rule_name, *args, **kwargs)
        @spud.invoke_rule(rule_name.to_s, *args, **kwargs)
      end

      def die(message = nil, code: 1)
        puts message if message
        raise Error, code
      end

      class ShOut < Struct.new(:status, :output); end
    end
  end
end
