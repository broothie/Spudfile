# typed: strict
require 'sorbet-runtime'

module Spud
  class Error < StandardError
    extend T::Sig

    sig {override.returns(String)}
    def message
      "spud: #{super}"
    end
  end
end
