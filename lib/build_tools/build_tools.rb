require_relative 'spud/spud'
require_relative 'make/make'
require_relative 'package.json/package.json'

module Spud
  module BuildTools
    BUILD_TOOLS = [
      SpudBuild::Build,
      Make,
      Node
    ]
  end
end
