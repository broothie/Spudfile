require 'spud/build_tools/spud/task'

module Spud
  module BuildTools
    module Spud
      module DSL
        class File
          def initialize(filename)
            @__filename = filename
          end

          def require_relative(name)
            require("./#{name}")
          end

          def task(name, dependencies = {}, &block)
            BuildTools::Spud::Task.new(
              name: BuildTools::Spud::Task.qualified_name(@__filename, name.to_s),
              filename: @__filename,
              dependencies: dependencies,
              &block
            )
          end

          def method_missing(name, *args, &block)
            task(name, *args, &block)
          end
        end
      end
    end
  end
end
