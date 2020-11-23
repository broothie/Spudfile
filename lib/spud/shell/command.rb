# typed: true
require 'sorbet-runtime'
require 'stringio'
require 'open3'
require 'spud/driver'
require 'spud/shell/result'

module Spud
  module Shell
    class Command
      extend T::Sig

      attr_reader :result

      Handle = T.type_alias {T.any(IO, StringIO)}

      sig {params(command: String, driver: T.nilable(Driver), silent: T::Boolean, handle: Handle).returns(Result)}
      def self.call(command, driver: nil, silent: false, handle: STDOUT)
        cmd = new(command, driver: driver, silent: silent, handle: handle)
        cmd.issue!
        cmd.result
      end

      sig {params(driver: Driver).returns(Commander)}
      def self.commander(driver)
        Commander.new(driver)
      end

      sig {params(command: String, driver: T.nilable(Driver), silent: T::Boolean, handle: Handle).void}
      def initialize(command, driver: nil, silent: false, handle: STDOUT)
        @command = command
        @driver = driver
        @silent = silent
        @handle = handle

        @result = T.let(nil, T.nilable(Result))
      end

      sig {void}
      def issue!
        capturer = StringIO.new

        Open3.popen2e(@command) do |_, out, thread|
          @driver&.register_subprocess(thread.pid)

          loop do
            line = out.gets
            break unless line

            @handle.write line unless @silent
            capturer.puts line
          end

          @result = Result.new(capturer.string, T.cast(thread.value, Process::Status))
        end

        @driver&.register_subprocess(nil)
      end

      class Commander
        extend T::Sig

        sig {params(driver: Driver).void}
        def initialize(driver)
          @driver = driver
        end

        sig {params(command: String, silent: T::Boolean, handle: Handle).returns(Result)}
        def call(command, silent: false, handle: STDOUT)
          Command.(command, driver: @driver, silent: silent, handle: handle)
        end
      end
    end
  end
end
