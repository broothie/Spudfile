# typed: strict
require 'sorbet-runtime'
require 'spud/cli/options'

module Spud
  module CLI
    class Results
      extend T::Sig

      sig {returns(T.nilable(String))}
      attr_accessor :task

      sig {returns(T::Array[String])}
      def ordered
        @ordered = T.let(@ordered, T.nilable(T::Array[String]))
        @ordered ||= []
      end

      sig {returns(T::Hash[String, String])}
      def named
        @named = T.let(@named, T.nilable(T::Hash[String, String]))
        @named ||= {}
      end

      sig {returns(Options)}
      def options
        @options = T.let(@options, T.nilable(Options))
        @options ||= Options.new
      end
    end
  end
end
