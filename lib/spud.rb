require 'stringio'
require_relative 'args'
require_relative 'version'
require_relative 'shell'
require_relative 'build_tools/build_tools'
require_relative 'build_tools/spud/shell_error'

module Spud
  def self.run!
    Spud.new.run!
  end

  class Spud
    attr_accessor :watch_process

    def run!
      puts options if debug?
      puts watches_present: watches_present? if debug?
      puts wait: wait? if debug?

      if help?
        print_help!
        return
      end

      if version?
        puts VERSION
        return
      end

      unless rule_present?
        print_rules!
        return
      end

      if watches_present?
        watch(options[:watches], rule_name, *args[:positional], **args[:keyword])
        return
      end

      invoke(rule_name, *args[:positional], **args[:keyword])
    rescue BuildTools::SpudBuild::ShellError => e
      raise e if debug?

    rescue => e
      raise e if debug?
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

      thread = nil
      timestamps = {}
      loop do
        begin
          filenames = Dir.glob(*globs)
          filenames.each do |filename|
            new_timestamp = File.mtime(filename)
            old_timestamp = timestamps[filename]

            if !old_timestamp || new_timestamp > old_timestamp
              timestamps[filename] = new_timestamp

              watch_process.kill! if watch_process
              thread.kill if thread

              thread = Thread.new { invoke(name, *args, **kwargs) }
              break
            end
          end

          sleep 0.1
        rescue Interrupt
          thread.kill if thread
          watch_process.kill! if watch_process
          break
        end
      end
    end

    def wait?
      @wait ||= !watches_present?
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
      longest_name = 0
      longest_filename = 0
      longest_positional = 0
      longest_keyword = 0
      table = []
      rules.each do |name, rule|
        longest_name = name.length if name.length > longest_name

        positional = rule.positional_params.map(&method(:wrap_param)).join(' ')
        longest_positional = positional.length if positional.length > longest_positional

        keyword = rule.keyword_params.map(&method(:prefix_param)).join(' ')
        longest_keyword = keyword.length if keyword.length > longest_keyword

        longest_filename = rule.filename.length if rule.filename.length > longest_filename

        table << [name, positional, keyword, rule.filename]
      end

      table.each do |(name, positional, keyword, filename)|
        fields = [name.ljust(longest_name)]
        fields << positional.ljust(longest_positional) unless longest_positional == 0
        fields << keyword.ljust(longest_keyword) unless longest_keyword == 0
        fields << filename.ljust(longest_filename)

        puts fields.join('  ')
      end
    end

    def wrap_param(name)
      "<#{name}>"
    end

    def prefix_param(name)
      name.length == 1 ? "-#{name}" : "--#{name}"
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
      help.puts '  -h, --help           show this help dialog'
      help.puts '  -v, --version        show spud version'
      help.puts '  -w, --watch <files>  watch files for changes'
      help.puts '  --debug              run in debug mode'

      puts help.string
    end

    # Options
    def watches_present?
      @watches_present ||= !options[:watches].empty?
    end

    %i[help version debug].each { |option| define_method("#{option}?") { options[option] } }

    # Args
    def rule_present?
      rule_name
    end

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
