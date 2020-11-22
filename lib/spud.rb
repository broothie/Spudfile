# typed: true
require_relative 'spud/driver'

module Spud
  def self.run!
    Driver.new.run!
  end
end
