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
      if options[:version]
        puts VERSION
        return
      end

      if !rule_name || options[:list]
        rules.keys.each(&method(:puts))
        return
      end

      invoke_rule(rule_name, *args[:positional], **args[:keyword])
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

    def invoke_rule(name, *args, **kwargs)
      rule = rules[name]
      raise Error, "no rule found for #{name}" unless rule
      rule.invoke(*args, **kwargs)
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
