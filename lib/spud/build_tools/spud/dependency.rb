module Spud
  module BuildTools
    module Spud
      class Dependency
        def initialize(source, target)
          @sources = [source].flatten
          @targets = [target].flatten
        end

        # @return [Boolean]
        def need_to_update?
          !up_to_date?
        end

        # @return [Boolean]
        def up_to_date?
          source_filenames = Dir[*@sources]
          return true if source_filenames.empty?

          newest_source = source_filenames
            .map(&File.method(:stat))
            .map(&:mtime)
            .max

          target_filenames = Dir[*@targets]
          return false if target_filenames.empty?

          oldest_target = target_filenames
            .map(&File.method(:stat))
            .map(&:mtime)
            .min

          newest_source < oldest_target
        end
      end
    end
  end
end
