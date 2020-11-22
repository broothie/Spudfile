# typed: true
require 'sorbet-runtime'

module Spud
  module CLI
    class Options
      extend T::Sig

      attr_writer :help
      attr_writer :files
      attr_writer :inspect

      sig {returns(T::Array[String])}
      def watches
        @watches = T.let(@watches, T.nilable(T::Array[String]))
        @watches ||= []
      end

      sig {returns(T::Boolean)}
      def help?
        !!@help
      end

      sig {returns(T::Boolean)}
      def files?
        !!@files
      end

      sig {returns(T::Boolean)}
      def inspect?
        !!@inspect
      end
    end
  end
end
