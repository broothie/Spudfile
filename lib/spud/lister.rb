require 'stringio'

module Spud
  class Lister
    # @param tasks [Array<BuildTools::Task>]
    def initialize(tasks)
      @tasks = tasks
    end

    # @return [void]
    def list!
      builder = StringIO.new

      @tasks.each do |task|
        builder.write task.name.ljust(max_task_length)

        if show_positional_args?
          builder.write '  '
          builder.write task.args.positional.join(' ').ljust(max_positional_string_length)
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

    # @return [void]
    def list_filenames!
      puts filenames.join("\n")
    end

    private

    # @return [Integer]
    def max_task_length
      @max_task_length ||= @tasks.map { |task| task.name.length }.max
    end

    # @return [Integer]
    def max_positional_string_length
      @max_positional_string_length ||= @tasks
        .map { |task| task.args.positional.join(' ') }
        .map(&:length)
        .max
    end

    # @return [Boolean]
    def show_positional_args?
      @show_positional_args ||= @tasks.any? { |task| task.args.any_positional? }
    end

    # @return [Integer]
    def max_named_string_length
      @max_named_string_length ||= @tasks
        .map { |task| task.args.named.join(' ') }
        .map(&:length)
        .max
    end

    # @return [Boolean]
    def show_named_args?
      @show_named_args ||= @tasks.any? { |task| task.args.any_named? }
    end

    # @return [Array<String>]
    def filenames
      @filenames ||= @tasks.map(&:filename).uniq
    end

    # @return [Boolean]
    def show_filenames?
      filenames.length > 1
    end
  end
end
