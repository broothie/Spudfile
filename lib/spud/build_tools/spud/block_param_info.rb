require 'spud/task_arg'

module Spud
  module BuildTools
    module Spud
      class BlockParamInfo
        # @param filename [String]
        # @param block [Proc]
        def initialize(filename, &block)
          @filename = filename
          @block = block
        end

        # @return [Array<Spud::TaskArg>]
        def task_args
          parameters.map do |type, name|
            case type
            when :req
              TaskArg.new(name, 'ordered')
            when :opt
              TaskArg.new(name, 'ordered', default: arg_values[name])
            when :keyreq
              TaskArg.new(name, 'named')
            when :key
              TaskArg.new(name, 'named', default: arg_values[name])
            end
          end
        end

        # @return [Array]
        def dummy_args
          [dummy_ordered_args, dummy_named_args]
        end

        # @return [Array<NilClass>]
        def dummy_ordered_args
          Array.new(parameters.count { |p| p.first == :req })
        end

        # @return [Hash{Symbol->NilClass}]
        def dummy_named_args
          parameters.select { |p| p.first == :keyreq }.map(&:last).each_with_object({}) { |n, h| h[n] = nil }
        end

        # @return [String]
        def arg_hash_string
          "{ #{parameters.map(&:last).map { |n| "#{n}: #{n}" }.join(', ')} }"
        end

        # @return [Hash]
        def arg_values
          @arg_values ||= begin
            ordered, named = dummy_args
            lambda(arg_hash_string).call(*ordered, **named)
          end
        end

        # @return [Array<Array<Symbol>>]
        def parameters
          @parameters ||= lambda.parameters
        end

        # @return [Proc]
        def lambda(body = nil)
          line = File.read(@filename).split("\n")[@block.source_location.last - 1]

          match = /(do|{)\s*\|(?<params>[^|]+)\|/.match(line)
          return -> {} unless match

          param_source = match[:params]
          param_source += ', _: nil, __: nil, ___: nil' if body
          eval "-> (#{param_source}) { #{body} }"
        end
      end
    end
  end
end
