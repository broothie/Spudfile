require_relative '../build_tool'
require_relative 'dsl/file_dsl'

module Spud::BuildTools
  module SpudBuild
    class Build < BuildTool
      attr_reader :rules

      def mount!
        filenames = Dir.glob('Spudfile') + Dir.glob('spuds/**.rb')

        @rules = {}
        filenames.each do |filename|
          source = File.read(filename)
          @ctx = FileDsl.new(@spud, filename)

          $LOAD_PATH << File.dirname(filename)
          @ctx.instance_eval(source)
          $LOAD_PATH.pop

          @rules.merge!(@ctx.__rules)
        end
      end
    end
  end
end
