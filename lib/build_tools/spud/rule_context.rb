require_relative 'shell_error'
require_relative '../../shell'
require_relative '../../error'

module Spud::BuildTools
  module SpudBuild
    def self.join_args(*args)
      args.join(' ')
    end

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

        out
      end

      def sh?(*args)
        cmd = SpudBuild.join_args(*args)
        puts cmd

        out = Spud::Shell.cmd(cmd)
        puts out

        out
      end

      def shh(*args)
        out = shh?(*args)
        raise ShellError unless out.status.exitstatus.zero?

        out
      end

      def shh?(*args)
        out = Spud::Shell.cmd(SpudBuild.join_args(*args))
        puts out

        out
      end

      def shhh(*args)
        out = shhh?(*args)
        raise ShellError, out unless out.status.exitstatus.zero?

        out
      end

      def shhh?(*args)
        Spud::Shell.cmd(SpudBuild.join_args(*args))
      end

      def invoke(rule_name, *args, **kwargs)
        @spud.invoke_rule(rule_name.to_s, *args, **kwargs)
      end

      def q(s)
        %('#{s}')
      end

      def qq(s)
        %("#{s}")
      end

      def method_missing(method_name, *args)
        method_name = method_name.to_s

        if method_name.end_with?('?')
          sh?(method_name.chomp('?'), *args)
        else
          sh(method_name, *args)
        end
      end
    end
  end
end
