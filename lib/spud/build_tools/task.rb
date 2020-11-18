module Spud
  module BuildTools
    class Task
      # @return [String]
      attr_reader :name
      # @return [String]
      attr_reader :filename
      # @return [Spud::TaskArgs]
      attr_reader :args

      # @return [void]
      def self.mount!
        raise NotImplementedError
      end

      # @param name [String]
      # @param filename [String]
      def initialize(name:, filename:)
        @name = name
        @filename = filename

        Runtime.tasks[name.to_s] = self
      end

      # @param positional [Array]
      # @param named [Hash]
      # @return [Object]
      def invoke(positional = [], named = {})
        raise NotImplementedError
      end
    end
  end
end
