module Spud
  module BuildTools
    class Task
      # @return [String]
      attr_reader :name
      # @return [String]
      attr_reader :filename

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
      # @return [Process::Status]
      def invoke(positional = [], named = {})
        raise NotImplementedError
      end

      # @return [Spud::TaskArgs]
      def args
        @args ||= TaskArgs.new([])
      end

      # @return [String]
      def details
        name
      end
    end
  end
end
