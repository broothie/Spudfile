# typed: true
require 'sorbet-runtime'
require 'spud/error'
require 'spud/driver'
require 'spud/shell/command'
require 'spud/shell/result'
require 'spud/task_runners/spud_task_runner/file_dsl'

module Spud
  module TaskRunners
    module SpudTaskRunner
      class TaskDSL
        extend T::Sig

        sig {params(driver: Driver, filename: String, file_dsl: FileDSL).void}
        def initialize(driver, filename, file_dsl)
          @__filename = filename
          @__driver = driver

          @__commander = Shell::Command.commander(driver)

          file_dsl.singleton_methods.each do |method|
            define_singleton_method(method, &file_dsl.singleton_method(method))
          end
        end

        sig {params(value: T.untyped).void}
        def halt(value = nil)
          value ? throw(:halt, value) : throw(:halt)
        end

        sig {params(command: String).returns(Shell::Result)}
        def sh(command)
          puts command
          @__commander.(command)
        end

        sig {params(command: String).returns(Shell::Result)}
        def shh(command)
          @__commander.(command)
        end

        sig {params(command: String).returns(Shell::Result)}
        def shhh(command)
          @__commander.(command, silent: true)
        end

        sig {params(command: String).returns(Shell::Result)}
        def sh!(command)
          puts command
          result = @__commander.(command)
          raise Error, "sh failed for '#{command}'" unless result.success?
          result
        end

        sig {params(command: String).returns(Shell::Result)}
        def shh!(command)
          result = @__commander.(command)
          raise Error, "sh failed for '#{command}'" unless result.success?
          result
        end

        sig {params(command: String).returns(Shell::Result)}
        def shhh!(command)
          result = @__commander.(command, silent: true)
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

        sig {params(task: Symbol, ordered: String, named: String).returns(T.untyped)}
        def method_missing(task, *ordered, **named)
          task = task.to_s
          task = task.include?('.') ? task : Task.qualified_name(@__filename, task)
          @__driver.invoke(task, ordered, named)
        end
      end
    end
  end
end
