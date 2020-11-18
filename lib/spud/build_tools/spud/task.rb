require 'spud/error'
require 'spud/task_args'
require 'spud/build_tools/task'
require 'spud/build_tools/spud/task'
require 'spud/build_tools/spud/dsl/file'
require 'spud/build_tools/spud/dsl/task'

module Spud
  module BuildTools
    module Spud
      class Task < BuildTools::Task
        # @return [void]
        def self.mount!
          Dir['**/Spudfile', '**/*.spud'].each do |filename|
            @filename = filename
            file_dsl.instance_eval(File.read(filename), filename)
          end

          @filename = nil
        end

        # @return [Spud::DSL::File]
        def self.file_dsl
          @file_dsl ||= DSL::File.new
        end

        # @param task [String]
        # @param block [Proc]
        # @return [void]
        def self.add_task(task, &block)
          raise "task '#{task}' somehow created without filename" unless @filename

          new(name: qualified_name(@filename, task.to_s), filename: @filename, &block)
        end

        # @param filename [String]
        # @param task [String]
        # @param positional [Array]
        # @param named [Hash]
        def self.invoke(filename, task, positional, named)
          task = task.to_s
          task_obj = task_for(filename, task)
          if task_obj
            Runtime.invoke(task_obj.name, positional, named)
          else
            Runtime.invoke(task, positional, named)
          end
        end

        # @param filename [String]
        # @param task [String]
        def self.task_for(filename, task)
          Runtime.tasks[qualified_name(filename, task.to_s)]
        end

        def self.qualified_name(filename, task)
          raise "task '#{task}' somehow created without filename" unless filename

          [qualified_prefix(filename), task.to_s].join('.').gsub(/^\./, '')
        end

        # @param filename [String]
        # @return [String]
        def self.qualified_prefix(filename)
          dirname = File.dirname(filename)
          dirname = '' if dirname == '.'

          basename = File.basename(filename, '.spud')
          basename_array = basename == 'Spudfile' ? [] : [basename]

          (dirname.split('/') + basename_array).join('.')
        end

        def initialize(name:, filename:, &block)
          super
          @block = block
        end

        # @param positional [Array]
        # @param named [Hash]
        # @return [Object]
        def invoke(positional, named)
          check_required!(positional)

          return task_dsl.instance_exec(*positional, &@block) unless args.any_named?

          task_dsl.instance_exec(*positional, **symbolize_keys(named), &@block)
        rescue ArgumentError => error
          raise Error, "invocation of '#{name}' with #{error.message}"
        end

        # @return [Spud::TaskArgs]
        def args
          @args ||= ::Spud::TaskArgs.from_block(filename, &@block)
        end

        private

        # @param positional [Array<String>]
        # @return [void]
        def check_required!(positional)
          required_positional = args.required_positional
          missing_positional = required_positional.length - positional.length
          if missing_positional > 0
            arguments = required_positional.length - missing_positional > 1 ? 'arguments' : 'argument'
            raise Error, "invocation of '#{name}' missing required #{arguments} #{required_positional.join(', ')}"
          end
        end

        # @return [Spud::DSL::Task]
        def task_dsl
          @task_dsl ||= DSL::Task.new(filename)
        end

        # @param hash [Hash]
        # @return [Hash]
        def symbolize_keys(hash)
          hash.each_with_object({}) do |(key, value), new_hash|
            new_hash[key.is_a?(String) ? key.to_sym : key] = value
          end
        end
      end
    end
  end
end
