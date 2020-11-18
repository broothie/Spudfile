require 'spud/build_tools/task'

module Spud
  module BuildTools
    module Make
      class Task < BuildTools::Task
        def self.mount!
          return unless File.exist?('Makefile')

          if `command -v make`.empty?
            puts 'Makefile detected, but no installation of `make` exists. Skipping make...'
            return
          end

          source = File.read('Makefile')
          source.scan(/^(\S+):.*/).map(&:first).each do |name|
            new(name: name, filename: 'Makefile')
          end
        end

        def invoke(*)
          system('make', name)
        end
      end
    end
  end
end
