require 'spud/build_tools/spud/task'

module Spud
  module BuildTools
    module Spud
      module DSL
        class File
          def require_relative(name)
            require("./#{name}")
          end

          def task(name, *, &block)
            BuildTools::Spud::Task.add_task(name, &block)
          end

          def method_missing(name, *args, &block)
            task(name, *args, &block)
          end
        end
      end
    end
  end
end
