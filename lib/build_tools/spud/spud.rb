require_relative '../build_tool'
require_relative 'file_context'

module Spud::BuildTools
  module SpudBuild
    class Build < BuildTool
      def mount!
        source = File.read('Spudfile')
        @ctx = FileContext.new(@spud)
        @ctx.instance_eval(source)
      end

      def rules
        @ctx.rules
      end
    end
  end
end
