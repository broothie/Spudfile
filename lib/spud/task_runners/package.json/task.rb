# typed: strict
require 'sorbet-runtime'
require 'json'
require 'spud/driver'
require 'spud/task_args'
require 'spud/shell/command'
require 'spud/task_runners/task'

module Spud
  module TaskRunners
    module PackageJSON
      class Task < TaskRunners::Task
        extend T::Sig

        sig {override.returns(String)}
        attr_reader :name

        sig {override.params(driver: Driver).returns(T::Array[TaskRunners::Task])}
        def self.tasks(driver)
          if File.exist?('package.lock')
            if `command -v npm`.empty?
              puts 'package.json detected, but no installation of `npm` exists. Skipping npm...'
              return []
            else
              command = 'npm'
            end
          elsif File.exist?('yarn.lock')
            if `command -v yarn`.empty?
              puts 'package.json detected, but no installation of `yarn` exists. Skipping yarn...'
              return []
            else
              command = 'yarn'
            end
          else
            return []
          end

          source = File.read('package.json')
          json = JSON.parse(source)
          scripts = json['scripts']
          return [] unless scripts

          scripts.keys.map { |name| new(driver, name, command, scripts) }
        end

        sig {params(driver: Driver, name: String, command: String, scripts: T::Hash[String, String]).void}
        def initialize(driver, name, command, scripts)
          @driver = driver
          @name = name
          @command = command
          @scripts = scripts
        end

        sig {override.params(ordered: T::Array[String], named: T::Hash[String, String]).returns(T.untyped)}
        def invoke(ordered, named)
          Shell::Command.("#{@command} run #{name}", driver: @driver)
        end

        sig {override.returns(String)}
        def filename
          'package.json'
        end

        sig {override.returns(String)}
        def details
          %({ "#{name}": "#{@scripts[name]}" })
        end
      end
    end
  end
end
