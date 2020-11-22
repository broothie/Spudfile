# typed: true
require 'sorbet-runtime'
require 'stringio'
require 'spud/task_runners/task'

module Spud
  class Lister
    extend T::Sig

    sig {params(tasks: T::Array[TaskRunners::Task]).void}
    def initialize(tasks)
      @tasks = tasks
    end

    sig {void}
    def list_tasks!
      builder = StringIO.new

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

        if show_filenames?
          builder.write '  '
          builder.write task.filename
        end

        builder.write "\n"
      end

      puts builder.string
    end

    sig {void}
    def list_filenames!
      puts filenames.join("\n")
    end

    sig {returns(T::Array[String])}
    def filenames
      @filenames ||= @tasks.map(&:filename).uniq
    end

    private

    sig {returns(Integer)}
    def max_task_length
      @max_task_length ||= @tasks.map { |task| task.name.length }.max
    end

    sig {returns(Integer)}
    def max_ordered_string_length
      @max_ordered_string_length ||= @tasks
        .map { |task| task.args.ordered.join(' ') }
        .map(&:length)
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
        .max
    end

    sig {returns(T::Boolean)}
    def show_named_args?
      @show_named_args ||= @tasks.any? { |task| task.args.any_named? }
    end

    sig {returns(T::Boolean)}
    def show_filenames?
      filenames.length > 1
    end
  end
end
