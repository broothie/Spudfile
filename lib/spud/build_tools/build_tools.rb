require 'spud/build_tools/spud/task'
require 'spud/build_tools/make/task'
require 'spud/build_tools/package.json/task'

module Spud
  module BuildTools
    BUILD_TOOLS = [
      Spud::Task,
      Make::Task,
      PackageJSON::Task,
    ]
  end
end
