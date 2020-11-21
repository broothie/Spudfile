require 'spud/cli/results'

module Spud
  module CLI
    class Parser
      # @return [Spud::CLI::Results]
      attr_reader :results

      # @return [void]
      def self.parse!
        parse(ARGV)
      end

      # @param args [Array<String>]
      # @return [Spud::CLI::Results]
      def self.parse(args)
        new(args).parse!
      end

      # @param args [Array<String>]
      def initialize(args)
        @args = args.dup
        @results = Results.new
      end

      # @return [void]
      def parse!
        parse_arg! until done?
        results
      end

      private

      # @return [void]
      def parse_arg!
        if before_task_name?
          flag? ? handle_option! : set_task_name!
        else
          if flag?
            results.named[lstrip_hyphens(take!)] = take!
          else
            results.positional << take!
          end
        end
      end

      # @return [void]
      def handle_option!
        flag = take!
        case flag
        when '-h', '--help' then options.help = true
        when '-w', '--watch' then options.watches << take!
        when '-f', '--files' then options.files = true
        when '-i', '--inspect' then options.inspect = true
        else raise Error, "invalid option: '#{flag}'"
        end
      end

      # @return [Spud::Options]
      def options
        results.options
      end

      # @param flag [String]
      # @return [String]
      def lstrip_hyphens(flag)
        flag.gsub(/^-+/, '')
      end

      # @return [Boolean]
      def before_task_name?
        !results.task
      end

      # @return [void]
      def set_task_name!
        results.task = take!
      end

      # @return [String]
      def take!
        @args.shift
      end

      # @return [String]
      def arg
        @args.first
      end

      # @return [Boolean]
      def flag?
        arg.start_with?('-')
      end

      # @return [Boolean]
      def done?
        @args.empty?
      end
    end
  end
end
