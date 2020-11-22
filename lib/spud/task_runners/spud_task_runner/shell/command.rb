# typed: true
require 'sorbet-runtime'
require 'stringio'
require 'open3'
require 'spud/driver'
require 'spud/task_runners/spud_task_runner/shell/result'

module Spud
  module TaskRunners
    module SpudTaskRunner
      module Shell
        class Command
          extend T::Sig

          attr_reader :result

          sig {params(driver: Driver, command: String, silent: T::Boolean, handle: T.any(IO, StringIO)).returns(Result)}
          def self.call(driver, command, silent: false, handle: STDOUT)
            cmd = new(driver, command, silent: silent, handle: handle)
            cmd.issue!
            cmd.result
          end

          sig {params(driver: Driver, command: String, silent: T::Boolean, handle: T.any(IO, StringIO)).void}
          def initialize(driver, command, silent: false, handle: STDOUT)
            @command = command
            @driver = driver
            @silent = silent
            @handle = handle

            @result = T.let(nil, T.nilable(Result))
          end

          sig {void}
          def issue!
            capturer = StringIO.new

            Open3.popen2e(@command) do |_stdin, stdout, thread|
              @driver.register_subprocess(thread.pid)

              loop do
                line = stdout.gets
                break unless line

                @handle.write line unless @silent
                capturer.puts line
              end

              @result = Result.new(capturer.string, T.cast(thread.value, Process::Status))
            end

            @driver.register_subprocess(nil)
          end
        end
      end
    end
  end
end
