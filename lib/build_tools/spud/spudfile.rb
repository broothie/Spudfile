
module Spud::BuildTools
  module SpudBuild
    class Spudfile
      def initialize(spud, source)
        @spud = spud
        @file_context = FileContext.new(@spud)

      end
    end
  end
end
