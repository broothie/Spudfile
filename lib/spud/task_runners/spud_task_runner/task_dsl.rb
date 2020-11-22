# typed: false
require 'sorbet-runtime'
require 'spud/error'
require 'spud/driver'
require 'spud/task_runners/spud_task_runner/shell/command'
require 'spud/task_runners/spud_task_runner/shell/result'

module Spud
  module TaskRunners
    module SpudTaskRunner
      class TaskDSL
        extend T::Sig

        sig {params(driver: Driver, filename: String).void}
        def initialize(driver, filename)
          @__filename = filename
          @__driver = driver
        end

        sig {params(command: String).returns(Shell::Result)}
        def sh(command)
          puts command
          Shell::Command.(@__driver, command)
        end

        sig {params(command: String).returns(Shell::Result)}
        def shh(command)
          Shell::Command.(@__driver, command)
        end

        sig {params(command: String).returns(Shell::Result)}
        def shhh(command)
          Shell::Command.(@__driver, command, silent: true)
        end

        sig {params(command: String).returns(Shell::Result)}
        def sh!(command)
          puts command
          result = Shell::Command.(@__driver, command)
          raise Error, "sh failed for '#{command}'" unless result.success?
          result
        end

        sig {params(command: String).returns(Shell::Result)}
        def shh!(command)
          result = Shell::Command.(@__driver, command)
          raise Error, "sh failed for '#{command}'" unless result.success?
          result
        end

        sig {params(command: String).returns(Shell::Result)}
        def shhh!(command)
          result = Shell::Command.(@__driver, command, silent: true)
          raise Error, "sh failed for '#{command}'" unless result.success?
          result
        end

        sig {params(task: String, ordered: String, named: String).returns(T.untyped)}
        def invoke(task, *ordered, **named)
          task = task.to_s
          task = task.include?('.') ? task : Task.qualified_name(@__filename, task)
          @__driver.invoke(task, ordered, named)
        rescue Error => error
          puts error.message
        end

        sig {params(task: String, ordered: String, named: String).returns(T.untyped)}
        def invoke!(task, *ordered, **named)
          task = task.to_s
          task = task.include?('.') ? task : Task.qualified_name(@__filename, task)
          @__driver.invoke(task, ordered, named)
        end

        def method_missing(symbol, *ordered, **named)
          task = symbol.to_s
          task = task.include?('.') ? task : Task.qualified_name(@__filename, task)
          @__driver.invoke(task, ordered, named)
        end
      end
    end
  end
end
