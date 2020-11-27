# typed: true
require 'sorbet-runtime'
require 'stringio'
require 'spud/task_runners/task'

module Spud
  class Lister
    extend T::Sig

    TASKS_HEADER = T.let('TASK', String)
    ORDERED_HEADER = T.let('ORDERED ARGS', String)
    NAMED_HEADER = T.let('NAMED ARGS', String)
    SOURCES_HEADER = T.let('SOURCE', String)

    sig {params(tasks: T::Array[TaskRunners::Task]).void}
    def initialize(tasks)
      @tasks = tasks
    end

    sig {void}
    def list_tasks!
      builder = StringIO.new

      if show_headers?
        builder.write TASKS_HEADER.ljust(max_task_length)

        if show_ordered_args?
          builder.write '  '
          builder.write ORDERED_HEADER.ljust(max_ordered_string_length)
        end

        if show_named_args?
          builder.write '  '
          builder.write NAMED_HEADER.ljust(max_named_string_length)
        end

        if show_sources?
          builder.write '  '
          builder.write SOURCES_HEADER
        end

        builder.write "\n"
      end

      @tasks.each do |task|
        builder.write task.name.ljust(max_task_length)

        if show_ordered_args?
          builder.write '  '
          builder.write task.args.ordered.join(' ').ljust(max_ordered_string_length)
        end

        if show_named_args?
          builder.write '  '
          builder.write task.args.named.join(' ').ljust(max_named_string_length)
        end

        if show_sources?
          builder.write '  '
          builder.write task.source
        end

        builder.write "\n"
      end

      puts builder.string
    end

    private

    sig {returns(T::Boolean)}
    def show_headers?
      @show_headers ||= show_ordered_args? || show_named_args? || show_sources?
    end

    sig {returns(Integer)}
    def max_task_length
      @max_task_length ||= @tasks
        .map { |task| task.name.length }
        .tap { |lengths| lengths.push(TASKS_HEADER.length) if show_headers? }
        .max
    end

    sig {returns(Integer)}
    def max_ordered_string_length
      @max_ordered_string_length ||= @tasks
        .map { |task| task.args.ordered.join(' ') }
        .map(&:length)
        .tap { |lengths| lengths.push(ORDERED_HEADER.length) if show_headers? }
        .max
    end

    sig {returns(T::Boolean)}
    def show_ordered_args?
      @show_ordered_args ||= @tasks.any? { |task| task.args.any_ordered? }
    end

    sig {returns(Integer)}
    def max_named_string_length
      @max_named_string_length ||= @tasks
        .map { |task| task.args.named.join(' ') }
        .map(&:length)
        .tap { |lengths| lengths.push(NAMED_HEADER.length) if show_headers? }
        .max
    end

    sig {returns(T::Boolean)}
    def show_named_args?
      @show_named_args ||= @tasks.any? { |task| task.args.any_named? }
    end

    sig {returns(T::Boolean)}
    def show_sources?
      sources.length > 1
    end

    sig {returns(T::Array[String])}
    def sources
      @filenames ||= @tasks.map(&:source).uniq
    end
  end
end
