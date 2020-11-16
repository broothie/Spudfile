module Spud
  module BuildTools
    class BuildTool
      def initialize(spud)
        @spud = spud
      end

      def name
        raise NotImplementedError
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
