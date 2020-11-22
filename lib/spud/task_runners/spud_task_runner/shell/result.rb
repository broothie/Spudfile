# typed: false
require 'sorbet-runtime'

module Spud
  module TaskRunners
    module SpudTaskRunner
      module Shell
        class Result < String
          extend T::Sig

          sig {returns(Process::Status)}
          attr_reader :status

          sig {params(output: String, status: Process::Status).void}
          def initialize(output, status)
            super(output)
            @status = status
          end

          def method_missing(symbol, *args)
            status.respond_to?(symbol) ? status.send(symbol, *args) : super
          end

          def respond_to_missing?(symbol, *)
            status.respond_to?(symbol) || super
          end
        end
      end
    end
  end
end
