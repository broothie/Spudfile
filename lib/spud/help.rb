# typed: true
require 'sorbet-runtime'
require 'stringio'
require 'spud/version'

module Spud
  module Help
    extend T::Sig

    sig {void}
    def self.print!
      puts <<~HELP
        spud #{VERSION}
        
        usage:
          spud [options] <task> [args]
        
        options:
          -h, --help          show this help dialog
          -w, --watch <glob>  re-run task any time glob changes
          -f, --files         list parsed files
          -i, --inspect       show details about a task
      HELP
    end
  end
end
