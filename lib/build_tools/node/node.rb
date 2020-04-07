require 'json'
require_relative '../build_tool'
require_relative '../build_rule'

module Spud::BuildTools
  class Node < BuildTool
    NAME = 'node'

    attr_reader :rules

    def mount!
      @rules = {}
      return unless File.exist?('package.json')

      scripts = JSON.parse(File.read('package.json'))['scripts']
      return unless scripts

      scripts.each { |name, source| @rules[name] = Rule.new(source) }
    end

    class Rule < BuildRule
      def initialize(source)
        @source = source
      end

      def invoke(*args, **kwargs)
        system(@source)
      end
    end
  end
end
