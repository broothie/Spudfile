# typed: true
require 'sorbet-runtime'
require 'yaml'
require 'spud/driver'
require 'spud/shell/command'
require 'spud/task_runners/task'

module Spud
  module TaskRunners
    module DockerCompose
      class Task < TaskRunners::Task
        extend T::Sig

        sig {override.returns(String)}
        attr_reader :name

        sig {override.params(driver: Driver).returns(T::Array[TaskRunners::Task])}
        def self.tasks(driver)
          return [] unless File.exist?('docker-compose.yml')

          if `command -v docker-compose`.empty?
            puts 'docker-compose.yml detected, but no installation of `docker-compose` exists. Skipping docker-compose...'
            return []
          end

          source = File.read('docker-compose.yml')
          contents = YAML.load(source)
          services = contents['services']
          services.map { |name, service| new(driver, name, service) }
        end

        sig {params(driver: Driver, name: String, service: T::Hash[String, T.untyped]).void}
        def initialize(driver, name, service)
          @driver = driver
          @name = name
          @service = service
        end

        sig {override.params(ordered: T::Array[String], named: T::Hash[String, String]).returns(T.untyped)}
        def invoke(ordered, named)
          system("docker-compose up #{@name} #{ordered.join(' ')}")
        end

        sig {override.returns(String)}
        def source
          'docker-compose.yml'
        end

        sig {override.returns(String)}
        def details
          YAML.dump(@name => @service)
        end
      end
    end
  end
end
