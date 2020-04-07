require_relative 'spud'

module Spud
  module Args
    class << self
      def parse_args!
        parse_args(ARGV)
      end

      def default_options
        {
          debug: false,
          list: false,
          version: false
        }
      end

      def parse_option(options, index, args)
        arg = args[index]

        case arg
        when '-v', '--version' then [options.merge(version: true), index + 1]
        when '-l', '--list' then [options.merge(list: true), index + 1]
        when '--debug' then [options.merge(debug: true), index + 1]
        else raise Error, "invalid option '#{arg}'"
        end
      end

      def parse_args(args)
        options = default_options.dup
        rule_name = nil
        index = 0
        while index < args.length
          arg = args[index]

          if arg[0] != '-'
            rule_name = arg
            index += 1
            break
          end

          options, index = parse_option(options, index, args)
        end

        positional = []
        keyword = {}
        while index < args.length
          arg = args[index]

          if arg[0] == '-'
            value = args[index + 1]
            raise Error, "missing value for arg #{arg}" unless value

            keyword[arg.sub(/^-+/, '').to_sym] = value
            index += 2
          else
            positional << arg
            index += 1
          end
        end

        {
          options: options,
          rule: rule_name,
          positional: positional,
          keyword: keyword
        }
      end
    end
  end
end
