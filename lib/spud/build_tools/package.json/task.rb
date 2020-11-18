require 'json'
require 'spud/build_tools/task'

module Spud
  module BuildTools
    module PackageJSON
      class Task < BuildTools::Task
        def self.mount!
          return unless File.exist?('package.json')

          opening_commands = %w[npm run]
          if File.exist?('package.lock')
            if `command -v npm`.empty?
              puts 'package.json detected, but no installation of `npm` exists. Skipping npm...'
              return
            end
          elsif File.exist?('yarn.lock')
            if `command -v yarn`.empty?
              puts 'package.json detected, but no installation of `yarn` exists. Skipping yarn...'
              return
            else
              opening_commands = %w[yarn run]
            end
          end

          source = File.read('package.json')
          json = JSON.parse(source)
          scripts = json['scripts']
          return unless scripts

          scripts.keys.each do |name|
            new(name: name, filename: 'package.json', opening_commands: opening_commands)
          end
        end

        def initialize(name:, filename:, opening_commands:)
          super(name: name, filename: filename)
          @opening_commands = opening_commands
        end

        def invoke(*)
          system(*(@opening_commands + [name]))
        end
      end
    end
  end
end
