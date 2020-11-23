# typed: true
require 'sorbet-runtime'

module Spud
  module TaskRunners
    module SpudTaskRunner
      class Dependency
        extend T::Sig

        sig {returns(T::Array[String])}
        attr_reader :sources

        sig {returns(T::Array[String])}
        attr_reader :targets

        sig {params(source: T.any(String, T::Array[String]), target: T.any(String, T::Array[String])).void}
        def initialize(source, target)
          @sources = [source].flatten
          @targets = [target].flatten
        end

        sig {returns(T::Boolean)}
        def need_to_update?
          !up_to_date?
        end

        sig {returns(T::Boolean)}
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
