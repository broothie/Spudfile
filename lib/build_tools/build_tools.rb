require_relative 'spud/spud'
require_relative 'make/make'
require_relative 'node/node'

module Spud
  module BuildTools
    BUILD_TOOLS = [
      SpudBuild::Build,
      Make,
      Node
    ]
  end
end
