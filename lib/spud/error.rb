# typed: true
module Spud
  class Error < StandardError
    # @return [String]
    def message
      "spud: #{super}"
    end
  end
end
