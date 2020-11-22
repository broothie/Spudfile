# typed: true
require 'sorbet-runtime'
require 'spud/cli/results'
require 'spud/cli/options'

module Spud
  module CLI
    class Parser
      extend T::Sig

      sig {returns(Results)}
      attr_reader :results

      sig {returns(Results)}
      def self.parse!
        parse(ARGV)
      end

      sig {params(args: T::Array[String]).returns(Results)}
      def self.parse(args)
        new(args).parse!
      end

      sig {params(args: T::Array[String]).void}
      def initialize(args)
        @args = args.dup
        @results = Results.new
      end

      sig {returns(Results)}
      def parse!
        parse_arg! until done?
        results
      end

      private

      sig {void}
      def parse_arg!
        if before_task_name?
          flag? ? handle_option! : set_task_name!
        else
          if flag?
            results.named[lstrip_hyphens(take!)] = take!
          else
            results.ordered << take!
          end
        end
      end

      sig {void}
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

      sig {returns(Options)}
      def options
        results.options
      end

      sig {params(flag: String).returns(String)}
      def lstrip_hyphens(flag)
        flag.gsub(/^-+/, '')
      end

      sig {returns(T::Boolean)}
      def before_task_name?
        !results.task
      end

      sig {void}
      def set_task_name!
        results.task = take!
      end

      sig {returns(String)}
      def take!
        @args.shift
      end

      # @return [String]
      sig {returns(String)}
      def arg
        @args.first
      end

      sig {returns(T::Boolean)}
      def flag?
        arg.start_with?('-')
      end

      sig {returns(T::Boolean)}
      def done?
        @args.empty?
      end
    end
  end
end
