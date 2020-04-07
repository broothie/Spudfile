require_relative 'file_context'
require_relative 'rule_context'
require_relative '../build_rule'

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
        RuleContext.new(@spud, @file_context).instance_exec(*args, **kwargs, &@block)
      end
    end
  end
end
