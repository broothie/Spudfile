# typed: true
require 'sorbet-runtime'
require 'spud/driver'
require 'spud/task_runners/spud_task_runner/task'

module Spud
  module TaskRunners
    module SpudTaskRunner
      class FileDSL
        extend T::Sig

        sig {params(driver: Driver, filename: String).returns(T::Array[SpudTaskRunner::Task])}
        def self.run(driver, filename)
          dsl = new(driver, filename)
          dsl.instance_eval(::File.read(filename), filename)

          dsl.instance_variable_get(:@__tasks)
        end

        sig {params(driver: Driver, filename: String).void}
        def initialize(driver, filename)
          @__driver = driver
          @__filename = filename

          @__tasks = T.let([], T::Array[Task])
        end

        sig {params(name: String).returns(T::Boolean)}
        def require_relative(name)
          require("./#{name}")
        end

        sig do
          params(
            name: T.any(String, Symbol),
            dependencies: T::Hash[T.any(String, T::Array[String]), T.any(String, T::Array[String])],
            block: Proc,
          ).void
        end
        def task(name, dependencies = {}, &block)
          @__tasks << Task.new(
            driver: @__driver,
            name: Task.qualified_name(@__filename, name.to_s),
            filename: @__filename,
            dependencies: dependencies,
            &block
          )
        end

        def method_missing(name, *args, &block)
          T.unsafe(self).task(name, *args, &block)
        end
      end
    end
  end
end
