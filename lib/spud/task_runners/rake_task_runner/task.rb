# typed: true
require 'sorbet-runtime'
require 'rake'
require 'spud/driver'
require 'spud/task_arg'
require 'spud/task_args'
require 'spud/task_runners/task'

module Spud
  module TaskRunners
    module RakeTaskRunner
      class Task < TaskRunners::Task
        extend T::Sig

        sig {override.params(driver: Driver).returns(T::Array[TaskRunners::Task])}
        def self.tasks(driver)
          app = Rake.application
          rakefile = app.find_rakefile_location&.first
          return [] if rakefile.nil?

          app.init('rake', [])
          app.load_rakefile

          app.tasks.map(&method(:new))
        end

        sig {params(task: Rake::Task).void}
        def initialize(task)
          @rake_task = task
        end

        sig {override.params(ordered: T::Array[String], named: T::Hash[String, String]).returns(T.untyped)}
        def invoke(ordered, named)
          T.unsafe(@rake_task).invoke(*ordered)
        end

        sig {override.returns(String)}
        def name
          @rake_task.name
        end

        sig {override.returns(String)}
        def source
          'rake'
        end

        sig {override.returns(TaskArgs)}
        def args
          TaskArgs.new(@rake_task.arg_names.map { |arg_name| TaskArg.new(arg_name.to_s, 'ordered') })
        end

        sig {override.returns(String)}
        def details
          "#{@rake_task.name_with_args}"
        end
      end
    end
  end
end
