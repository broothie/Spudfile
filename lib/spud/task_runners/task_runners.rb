# typed: true
require 'sorbet-runtime'
require 'spud/task_runners/task'
require 'spud/task_runners/spud_task_runner/task'
require 'spud/task_runners/rake_task_runner/task'
require 'spud/task_runners/make/task'
require 'spud/task_runners/package.json/task'
require 'spud/task_runners/docker-compose/task'

module Spud
  module TaskRunners
    extend T::Sig

    sig {returns(T::Array[T.class_of(Task)])}
    def self.get
      # Ordered by priority
      runners = [
        SpudTaskRunner::Task,
        RakeTaskRunner::Task,
        Make::Task,
        PackageJSON::Task,
        DockerCompose::Task,
      ]

      T.let(runners, T::Array[T.class_of(Task)])
    end
  end
end
