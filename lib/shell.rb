require 'stringio'
require 'open3'

module Spud
  class Shell < String
    def self.async(cmd, silent: false)
      call(cmd, silent: silent, wait: false)
    end

    def self.sync(cmd, silent: false)
      call(cmd, silent: silent)
    end

    def self.call(cmd, silent: false, wait: true)
      new(cmd, silent: silent, wait: wait)
    end

    def initialize(cmd, silent: false, wait: true)
      output = StringIO.new

      stdin, out, @status = Open3.popen2e(cmd)
      @thread = Thread.new do
        while line = out.gets
          puts line unless silent
          output.puts line
          super(output.string)
        end

        out.close
        stdin.close
      end

      @thread.join if wait
    end

    def status
      @status.value
    end

    def wait!
      @thread.join
    end

    def kill!
      Process.kill('KILL', @status.pid)
      @thread.kill
      @thread.join
    end
  end
end
