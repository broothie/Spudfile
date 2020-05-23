module Spud
  module BuildTools
    class BuildRule
      def invoke(*args, **kwargs)
        raise NotImplementedError
      end

      def filename
        raise NotImplementedError
      end

      def positional_params
        []
      end

      def keyword_params
        []
      end
    end
  end
end
