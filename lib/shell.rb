module Spud
  class Shell < String
    attr_accessor :status

    def self.cmd(cmd)
      new(`#{cmd}`, $?)
    end

    def initialize(output, status)
      super(output)
      @status = status
    end
  end
end
