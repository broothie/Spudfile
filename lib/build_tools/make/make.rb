require_relative '../build_tool'
require_relative '../build_rule'

module Spud::BuildTools
  class Make < BuildTool
    attr_reader :rules

    def mount!
      @rules = {}
      return unless File.exist?('Makefile')

      source = File.read('Makefile')
      source.scan(/^(\S+):.*/).each do |match|
        name = match.first
        @rules[name] = Rule.new(name)
      end
    end
  end

  class Rule < BuildRule
    def initialize(name)
      @name = name
    end

    def invoke(*args, **kwargs)
      system('make', @name, *args)
    end

    def filename
      'Makefile'
    end
  end
end
