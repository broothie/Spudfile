require 'open3'

module Spud
  class Shell < String
    attr_accessor :status

    def initialize(cmd, silent: false)
      @pid = nil
      @status = nil
      output = StringIO.new

      Open3.popen3(cmd) do |_, stdout, _, thread|
        @pid = thread.pid

        begin
          while line = stdout.gets
            puts line unless silent
            output.puts line
          end
        rescue Interrupt
          break
        end
      end

      @status = $?
      super(output.string)
    end

    def kill!
      Process.kill('HUP', @pid)
    end
  end
end
