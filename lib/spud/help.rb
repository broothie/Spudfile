require 'stringio'
require 'spud/version'

module Spud
  module Help
    # @return [void]
    def self.print!
      puts <<~HELP
        spud #{VERSION}
        
        usage:
          spud [options] <task> [args]
        
        options:
          -h, --help          show this help dialog
          -w, --watch <file>  re-run task any time it's dependencies change
          -f, --files         list parsed files
          -i, --inspect       show details about a task
      HELP
    end
  end
end
