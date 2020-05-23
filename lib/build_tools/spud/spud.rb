require_relative '../build_tool'
require_relative 'file_context'

module Spud::BuildTools
  module SpudBuild
    class Build < BuildTool
      attr_reader :rules

      def mount!
        filenames = Dir.glob('Spudfile')
        filenames += Dir.glob('spuds/*.rb')

        @rules = {}
        filenames.each do |filename|
          source = File.read(filename)
          @ctx = FileContext.new(@spud, filename)

          $LOAD_PATH << File.dirname(filename)
          @ctx.instance_eval(source)
          $LOAD_PATH.pop

          @rules.merge!(@ctx.__rules)
        end
      end
    end
  end
end
