require 'stringio'

require_relative 'args'
require_relative 'version'
require_relative 'build_tools/build_tools'
require_relative 'build_tools/spud/shell_error'

module Spud
  def self.run!
    Spud.new.run!
  end

  class Spud
    def run!
      if options[:help]
        print_help!
        return
      end

      if options[:version]
        puts VERSION
        return
      end

      unless rule_name
        print_rules!
        return
      end

      unless options[:watches].empty?
        watch(options[:watches], rule_name, *args[:positional], **args[:keyword])
        return
      end

      invoke(rule_name, *args[:positional], **args[:keyword])
    rescue BuildTools::SpudBuild::ShellError => e
      raise e if options[:debug]

    rescue Error => e
      raise e if options[:debug]
      puts e.message
      exit(1)

    rescue => e
      raise e if options[:debug]
      puts e.message
    end

    def invoke(name, *args, **kwargs)
      rule = rules[name.to_s]
      raise Error, "no rule found for '#{name}'" unless rule
      rule.invoke(*args, **kwargs)
    end

    def watch(globs, name, *args, **kwargs)
      rule = rules[name.to_s]
      raise Error, "no rule found for '#{name}'" unless rule

      timestamps = {}
      loop do
        begin
          Dir.glob(*globs).each do |filename|
            new_timestamp = File.mtime(filename)
            old_timestamp = timestamps[filename]
            unless old_timestamp
              timestamps[filename] = new_timestamp
              next
            end

            if new_timestamp > old_timestamp
              timestamps[filename] = new_timestamp
              invoke(name, *args, **kwargs)
              break
            end
          end

          sleep 0.1
        rescue Interrupt
          break
        end
      end
    end

    private

    # Rules
    def rules
      @rules ||= build_tools.reduce({}) { |rules, tool| rules.merge(tool.rules) }
    end

    def build_tools
      @build_tools ||= BuildTools::BUILD_TOOLS
        .reverse
        .map { |tool| tool.new(self) }
        .each(&:mount!)
    end

    def print_rules!
      table = rules.map { |name, rule| [name, rule.filename] }
      table.unshift(%w[RULE FILENAME])

      longest_rule = 'RULE'.length
      longest_filename = 'FILENAME'.length
      table.each do |(rule, filename)|
        longest_rule = rule.length if rule.length > longest_rule
        longest_filename = filename.length if filename.length > longest_filename
      end

      table.each do |(rule, filename)|
        puts "#{rule.ljust(longest_rule)}  #{filename.ljust(longest_filename)}"
      end
    end

    # Help
    def print_help!
      help = StringIO.new

      help.puts "spud #{VERSION}"
      help.puts
      help.puts 'usage:'
      help.puts '  spud [options] <rule> [args]'
      help.puts
      help.puts 'options:'
      help.puts '  -h, --help     show this help dialog dialog'
      help.puts '  -v, --version  show spud version'
      help.puts '  --debug        run in debug mode'

      puts help.string
    end

    # Args
    def options
      @options ||= args[:options]
    end

    def rule_name
      @rule_name ||= args[:rule]
    end

    def args
      @args ||= Args.parse_args!
    end
  end
end
