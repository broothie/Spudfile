# typed: strict
require 'sorbet-runtime'
require 'forwardable'

module Spud
  module Shell
    class Result < String
      extend T::Sig
      extend Forwardable

      sig {returns(Process::Status)}
      attr_reader :status

      def_delegators :status,
        :coredump?,
        :exited?,
        :exitstatus,
        :pid,
        :signaled?,
        :stopped?,
        :stopsig,
        :success?,
        :termsig,
        :to_i

      sig {params(output: String, status: Process::Status).void}
      def initialize(output, status)
        super(output)
        @status = status
      end
    end
  end
end
