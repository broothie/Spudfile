require 'stringio'
require 'spud/version'

module Spud
  module Help
    # @return [void]
    def self.print!
      help = StringIO.new

      help.puts "spud #{VERSION}"
      help.puts
      help.puts 'usage:'
      help.puts '  spud [options] <task> [args]'
      help.puts
      help.puts 'options:'
      help.puts '  -h, --help     show this help dialog'
      help.puts '  -f, --files    list parsed files'
      help.puts '  -i, --inspect  show details about a task'
      help.puts '  --debug        run in debug mode'

      puts help.string
    end
  end
end
