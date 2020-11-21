require 'spud/error'
require 'spud/help'
require 'spud/lister'
require 'spud/watch'
require 'spud/cli/parser'
require 'spud/build_tools/task'
require 'spud/build_tools/build_tools'

module Spud
  module Runtime
    class << self
      # @return [void]
      def run!
        if debug?
          puts "options: #{options.inspect}"
          puts "task: #{args.task}"
          puts "positional: #{args.positional}"
          puts "named: #{args.named}"
        end

        if options.help?
          Spud::Help.print!
          return
        end

        mount!
        if options.files?
          lister.list_filenames!
          return
        end

        if options.inspect?
          puts get_task(args.task).details
          return
        end

        unless args.task
          lister.list!
          return
        end

        unless options.watches.empty?
          watch!
          return
        end

        invoke!
      rescue Error => error
        puts error.message
        raise error if debug?
      rescue => error
        puts "fatal: #{error.message}"
        raise error if debug?
      end

      # @param task_name [String]
      # @param positional [Array]
      # @param named [Hash]
      def invoke(task_name, positional = [], named = {})
        get_task(task_name).invoke(positional, named)
      end

      # @return [Hash{String->Spud::Task}]
      def tasks
        @tasks ||= {}
      end

      # @return [Boolean]
      def debug?
        @debug ||= ENV['SPUD_DEBUG']
      end

      private

      # @return [void]
      def invoke!
        invoke(args.task, args.positional, args.named)
      end

      # @return [void]
      def watch!
        Watch.run!(
          task: args.task,
          positional: args.positional,
          named: args.named,
          watches: options.watches,
        )
      end

      # @param task_name [String]
      # @return [Spud::Task]
      def get_task(task_name)
        task = tasks[task_name.to_s]
        raise Error, "no task found for '#{task_name}'" unless task

        task
      end

      # @return [Array<String>]
      def filenames
        @filenames ||= tasks.values.map(&:filename).uniq
      end

      # @return [void]
      def mount!
        build_tools.each(&:mount!)
        tasks.keys.each do |key|
          tasks[key.to_s] = tasks.delete(key) if key.is_a?(Symbol)
        end
      end

      # @return [Array<Spud::BuildTools::Task>]
      def build_tools
        @build_tools ||= begin
          BuildTools::BUILD_TOOLS.each do |tool|
            raise "build tool does not inherit from BuildTools::Task" unless tool < BuildTools::Task
          end

          BuildTools::BUILD_TOOLS.reverse
        end
      end

      # @return [Spud::Options]
      def options
        args.options
      end

      # @return [Spud::CLI::Results]
      def args
        @args ||= Spud::CLI::Parser.parse!
      end

      # @return [Spud::Lister]
      def lister
        @lister ||= Lister.new(tasks.values)
      end
    end
  end
end
