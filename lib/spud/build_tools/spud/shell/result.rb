module Spud
  module BuildTools
    module Spud
      module Shell
        class Result < String
          attr_reader :status

          # @param output [String]
          # @param status [Process::Status]
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
