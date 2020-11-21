require 'stringio'
require 'spud/error'
require 'spud/task_args'
require 'spud/build_tools/task'
require 'spud/build_tools/spud/dependency'
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
            DSL::File.new(filename).instance_eval(File.read(filename), filename)
          end
        end

        # @param filename [String]
        # @param task [String]
        # @param positional [Array]
        # @param named [Hash]
        def self.invoke(filename:, task:, positional:, named:)
          if task.include?('.')
            Runtime.invoke(task, positional, named)
          else
            Runtime.invoke(qualified_name(filename, task), positional, named)
          end
        end

        # @param filename [String]
        # @param task [String]
        # @return [BuildTools::Spud::Task]
        def self.task_for(filename, task)
          Runtime.tasks[qualified_name(filename, task)]
        end

        # @param filename [String]
        # @param task [String]
        # @return [String]
        def self.qualified_name(filename, task)
          [qualified_prefix(filename), task].join('.').gsub(/^\./, '')
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

        # @param name [String]
        # @param filename [String]
        # @param dependencies [Hash]
        # @param block [Proc]
        def initialize(name:, filename:, dependencies:, &block)
          super(name: name, filename: filename)
          @dependencies = dependencies.map { |to, from| Dependency.new(to, from) }
          @block = block
        end

        # @param positional [Array]
        # @param named [Hash]
        # @return [Object]
        def invoke(positional, named)
          if up_to_date?
            puts "'#{name}' up to date"
            return
          end

          check_required_args!(positional)

          return task_dsl.instance_exec(*positional, &@block) unless args.any_named?

          task_dsl.instance_exec(*positional, **symbolize_keys(named), &@block)
        rescue ArgumentError => error
          raise Error, "invocation of '#{name}' with #{error.message}"
        end

        # @return [Spud::TaskArgs]
        def args
          @args ||= ::Spud::TaskArgs.from_block(filename, &@block)
        end

        # @return [String]
        def details
          filename, line_cursor = @block.source_location
          line_cursor -= 1

          lines = File.read(filename).split("\n")
          builder = StringIO.new

          while lines[line_cursor - 1] && lines[line_cursor - 1].start_with?('#')
            line_cursor -= 1
          end

          while lines[line_cursor].start_with?('#')
            builder.puts lines[line_cursor]
            line_cursor += 1
          end

          until lines[line_cursor].start_with?('end')
            builder.puts lines[line_cursor]
            line_cursor += 1
          end

          builder.puts lines[line_cursor]
          builder.string
        end

        private

        # @param positional [Array<String>]
        # @return [void]
        def check_required_args!(positional)
          required_positional = args.required_positional
          missing_positional = required_positional.length - positional.length
          if missing_positional > 0
            arguments = required_positional.length - missing_positional > 1 ? 'arguments' : 'argument'
            raise Error, "invocation of '#{name}' missing required #{arguments} #{required_positional.join(', ')}"
          end
        end

        # @return [Boolean]
        def up_to_date?
          return false if @dependencies.empty?

          @dependencies.all?(&:up_to_date?)
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
