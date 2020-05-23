require 'open3'

module Spud
  class Shell < String
    attr_accessor :status

    def initialize(cmd, silent: false)
      output = StringIO.new

      _, out, @thread = Open3.popen2e(cmd)
      @status = @thread.value
      while line = out.gets
        puts line
        output.puts line
      end

      super(output.string)
    end

    def kill!
      thread.kill
      thread.join
    end
  end
end
