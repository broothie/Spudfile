require 'spud/error'
require 'spud/build_tools/spud/task'
require 'spud/build_tools/spud/shell/command'

module Spud
  module BuildTools
    module Spud
      module DSL
        class Task
          def initialize(filename)
            @__filename = filename
          end

          def sh(command)
            puts command
            Shell::Command.(command)
          end

          def shh(command)
            Shell::Command.(command)
          end

          def shhh(command)
            Shell::Command.(command, silent: true)
          end

          def sh!(command)
            puts command
            result = Shell::Command.(command)
            raise Error, "sh failed for '#{command}'" unless result.success?
            result
          end

          def shh!(command)
            result = Shell::Command.(command)
            raise Error, "sh failed for '#{command}'" unless result.success?
            result
          end

          def shhh!(command)
            result = Shell::Command.(command, silent: true)
            raise Error, "sh failed for '#{command}'" unless result.success?
            result
          end

          def invoke(task, *positional, **named)
            invoke!(task, *positional, **named)
          rescue Error => error
            puts error.message
            raise error if Runtime.debug?
          end

          def invoke!(task, *positional, **named)
            Spud::Task.invoke(
              filename: @__filename,
              task: task.to_s,
              positional: positional,
              named: named,
            )
          end

          def method_missing(symbol, *positional, **named)
            invoke(@__filename, symbol, *positional, **named)
          end
        end
      end
    end
  end
end
