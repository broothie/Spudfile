require 'stringio'
require 'open3'
require 'spud/build_tools/spud/shell/result'

module Spud
  module BuildTools
    module Spud
      module Shell
        class Command
          attr_reader :result

          # @param command [String]
          # @param silent [Boolean]
          # @param handle [IO]
          def self.call(command, silent: false, handle: STDOUT)
            cmd = new(command, silent: silent, handle: handle)
            cmd.issue!
            cmd.result
          end

          # @param command [String]
          # @param silent [Boolean]
          # @param handle [IO]
          def initialize(command, silent: false, handle: STDOUT)
            @command = command
            @silent = silent
            @handle = handle

            @result = nil
          end

          # @return [void]
          def issue!
            capturer = StringIO.new

            Open3.popen2e(@command) do |_stdin, stdout, thread|
              loop do
                line = stdout.gets
                break unless line

                @handle.write line unless @silent
                capturer.puts line
              end

              @result = Result.new(capturer.string, thread.value)
            end
          end
        end
      end
    end
  end
end
