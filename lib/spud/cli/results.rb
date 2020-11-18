require 'spud/options'

module Spud
  module CLI
    class Results
      # @return [String]
      attr_accessor :task

      # @return [Spud::Options]
      def options
        @options ||= Options.new
      end

      # @return [Array<String>]
      def positional
        @positional ||= []
      end

      # @return [Hash{String->String}]
      def named
        @named ||= {}
      end
    end
  end
end
