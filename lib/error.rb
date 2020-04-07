module Spud
  class Error < StandardError
    def message
      "spud: #{super}"
    end
  end
end
