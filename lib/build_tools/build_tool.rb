module Spud
  module BuildTools
    class BuildTool
      NAME = nil

      def initialize(spud)
        @spud = spud
      end

      def mount!
        raise NotImplementedError
      end

      def rules
        raise NotImplementedError
      end
    end
  end
end
