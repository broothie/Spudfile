# typed: strict
require 'sorbet-runtime'
require 'spud/task_runners/task'
require 'spud/task_runners/spud_task_runner/task'
require 'spud/task_runners/make/task'
require 'spud/task_runners/package.json/task'

module Spud
  module TaskRunners
    extend T::Sig

    sig {returns(T::Array[T.class_of(Task)])}
    def self.get
      # Ordered by priority
      T.let(
        [
          T.let(SpudTaskRunner::Task, T.class_of(Task)),
          T.let(Make::Task, T.class_of(Task)),
          T.let(PackageJSON::Task, T.class_of(Task)),
        ],
        T::Array[T.class_of(Task)]
      )
    end
  end
end
