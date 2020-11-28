# typed: strict
require 'sorbet-runtime'
require 'spud/driver'
require 'spud/task_args'

module Spud
  module TaskRunners
    class Task
      extend T::Sig
      extend T::Helpers
      abstract!

      sig {abstract.params(driver: Driver).returns(T::Array[TaskRunners::Task])}
      def self.tasks(driver); end

      sig {abstract.returns(String)}
      def name; end

      sig {abstract.returns(String)}
      def source; end

      sig {abstract.params(ordered: T::Array[String], named: T::Hash[String, String]).returns(T.untyped)}
      def invoke(ordered, named); end

      sig {overridable.returns(T::Array[String])}
      def watches
        []
      end

      sig {overridable.returns(TaskArgs)}
      def args
        TaskArgs.new([])
      end

      sig {overridable.returns(String)}
      def details
        name
      end
    end
  end
end
