# typed: true
require 'sorbet-runtime'
require 'stringio'
require 'spud/driver'
require 'spud/error'
require 'spud/task_args'
require 'spud/task_runners/task'
require 'spud/task_runners/spud_task_runner/dependency'
require 'spud/task_runners/spud_task_runner/task'
require 'spud/task_runners/spud_task_runner/file_dsl'
require 'spud/task_runners/spud_task_runner/task_dsl'

module Spud
  module TaskRunners
    module SpudTaskRunner
      class Task < TaskRunners::Task
        extend T::Sig

        sig {override.returns(String)}
        attr_reader :filename

        sig {override.returns(String)}
        attr_reader :name

        sig {returns(T::Array[Dependency])}
        attr_reader :dependencies

        sig {override.params(driver: Driver).returns(T::Array[TaskRunners::Task])}
        def self.tasks(driver)
          Dir['**/Spudfile', '**/*.spud'].flat_map { |filename| FileDSL.run(driver, filename) }
        end

        sig {params(filename: String, name: String).returns(String)}
        def self.qualified_name(filename, name)
          segments = File.dirname(filename)
            .split('/')
            .reject { |segment| segment == '.' }

          basename = File.basename(filename, '.spud')
          segments << basename unless basename == 'Spudfile'

          segments << name
          segments.join('.')
        end

        sig do
          params(
            driver: Driver,
            name: String,
            filename: String,
            dependencies: T::Hash[T.any(String, T::Array[String]), T.any(String, T::Array[String])],
            file_dsl: FileDSL,
            block: Proc,
          )
          .void
        end
        def initialize(driver:, name:, filename:, dependencies:, file_dsl:, &block)
          @driver = driver
          @name = name
          @filename = filename
          @dependencies = dependencies.map { |to, from| Dependency.new(to, from) }
          @file_dsl = file_dsl
          @block = block
        end

        sig {override.params(ordered: T::Array[String], named: T::Hash[String, String]).returns(T.untyped)}
        def invoke(ordered, named)
          if up_to_date?
            raise Error, "'#{name}' up to date"
          end

          check_required_args!(ordered)

          catch :halt do
            if args.any_named?
              T.unsafe(task_dsl).instance_exec(*ordered, **symbolize_keys(named), &@block)
            else
              T.unsafe(task_dsl).instance_exec(*ordered, &@block)
            end
          end
        rescue ArgumentError => error
          raise Error, "invocation of '#{name}' with #{error.message}"
        end

        sig {override.returns(TaskArgs)}
        def args
          @args ||= TaskArgs.from_block(filename, &@block)
        end

        sig {override.returns(String)}
        def details
          filename, line_cursor = @block.source_location
          line_cursor -= 1

          lines = File.read(filename).split("\n")
          builder = StringIO.new

          # Move up for comments
          while lines[line_cursor - 1]&.start_with?('#')
            line_cursor -= 1
          end

          # Capture comments
          while lines[line_cursor]&.start_with?('#')
            builder.puts lines[line_cursor]
            line_cursor += 1
          end

          # Capture block
          until lines[line_cursor - 1]&.start_with?('end')
            builder.puts lines[line_cursor]
            line_cursor += 1
          end

          builder.string
        end

        private

        sig {params(ordered: T::Array[String]).void}
        def check_required_args!(ordered)
          required_ordered = args.required_ordered
          missing_ordered = required_ordered.length - ordered.length
          if missing_ordered > 0
            arguments = required_ordered.length - missing_ordered > 1 ? 'arguments' : 'argument'
            raise Error, "invocation of '#{name}' missing required #{arguments} #{required_ordered.join(', ')}"
          end
        end

        sig {returns(T::Boolean)}
        def up_to_date?
          return false if @dependencies.empty?

          @dependencies.all?(&:up_to_date?)
        end

        sig {returns(TaskDSL)}
        def task_dsl
          @task_dsl ||= TaskDSL.new(@driver, @filename, @file_dsl)
        end

        sig {params(hash: T::Hash[T.any(String, Symbol), T.untyped]).returns(T::Hash[Symbol, T.untyped])}
        def symbolize_keys(hash)
          hash.each_with_object({}) { |(key, value), new_hash| new_hash[key.to_sym] = value }
        end
      end
    end
  end
end
