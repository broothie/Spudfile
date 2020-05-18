module Spud
  module BuildTools
    class BuildRule
      def invoke(*args, **kwargs)
        raise NotImplementedError
      end

      def filename
        raise NotImplementedError
      end
    end
  end
end
