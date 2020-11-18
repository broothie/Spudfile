require 'spud/task_arg'
require 'spud/build_tools/spud/block_param_info'

module Spud
  class TaskArgs < Array
    # @param filename [String]
    # @param block [Proc]
    # @return [Spud::TaskArgs]
    def self.from_block(filename, &block)
      info = BuildTools::Spud::BlockParamInfo.new(filename, &block)
      new(info.task_args)
    end

    # @param task_args [Array<Spud::TaskArg>]
    def initialize(task_args)
      super(task_args)
    end

    # @return [Array<Spud::TaskArg>]
    def positional
      @positional ||= select(&:positional?)
    end

    # @return [Array<Spud::TaskArg>]
    def required_positional
      @required_positional ||= positional.select(&:required?)
    end

    # @return [Boolean]
    def any_positional?
      !positional.empty?
    end

    # @return [Array<Spud::TaskArg>]
    def named
      @named ||= select(&:named?)
    end

    # @return [Array<Spud::TaskArg>]
    def required_named
      @required_named ||= named.select(&:required?)
    end

    # @return [Boolean]
    def any_named?
      !named.empty?
    end
  end
end
