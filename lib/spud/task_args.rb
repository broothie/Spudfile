# typed: true
require 'sorbet-runtime'
require 'spud/task_arg'
require 'spud/block_param_info'

module Spud
  class TaskArgs < Array
    extend T::Sig

    sig {params(filename: String, block: Proc).returns(T.attached_class)}
    def self.from_block(filename, &block)
      info = BlockParamInfo.new(filename, &block)
      new(info.task_args)
    end

    sig {params(task_args: T::Array[TaskArg]).void}
    def initialize(task_args)
      super(task_args)
    end

    sig {returns(T::Array[TaskArg])}
    def ordered
      @ordered ||= select(&:ordered?)
    end

    sig {returns(T::Array[TaskArg])}
    def required_ordered
      @required_ordered ||= ordered.select(&:required?)
    end

    sig {returns(T::Boolean)}
    def any_ordered?
      !ordered.empty?
    end

    sig {returns(T::Array[TaskArg])}
    def named
      @named ||= select(&:named?)
    end

    sig {returns(T::Array[TaskArg])}
    def required_named
      @required_named ||= named.select(&:required?)
    end

    sig {returns(T::Boolean)}
    def any_named?
      !named.empty?
    end
  end
end
