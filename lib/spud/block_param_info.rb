# typed: true
require 'sorbet-runtime'
require 'spud/task_arg'

module Spud
  class BlockParamInfo
    extend T::Sig

    sig {params(filename: String, block: Proc).void}
    def initialize(filename, &block)
      @filename = filename
      @block = block
    end

    sig {returns(T::Array[TaskArg])}
    def task_args
      parameters.map do |type, name|
        name_string = name.to_s

        case type
        when :req
          TaskArg.new(name_string, 'ordered')
        when :opt
          TaskArg.new(name_string, 'ordered', default: arg_values[name])
        when :keyreq
          TaskArg.new(name_string, 'named')
        when :key
          TaskArg.new(name_string, 'named', default: arg_values[name])
        else
          raise "invalid proc arg type: '#{type}'"
        end
      end
    end

    sig {returns([T::Array[NilClass], T::Hash[Symbol, NilClass]])}
    def dummy_args
      [dummy_ordered_args, dummy_named_args]
    end

    sig {returns(T::Array[NilClass])}
    def dummy_ordered_args
      Array.new(parameters.count { |p| p.first == :req })
    end

    sig {returns(T::Hash[Symbol, NilClass])}
    def dummy_named_args
      parameters.select { |p| p.first == :keyreq }.map(&:last).each_with_object({}) { |n, h| h[n] = nil }
    end

    sig {returns(String)}
    def arg_hash_string
      "{ #{parameters.map(&:last).map { |n| "#{n}: #{n}" }.join(', ')} }"
    end

    sig {returns(T::Hash[Symbol, T.nilable(String)])}
    def arg_values
      @arg_values ||= begin
        ordered, named = dummy_args
        T.unsafe(lambda(arg_hash_string)).call(*ordered, **named)
      end
    end

    sig {returns(T::Array[[Symbol, Symbol]])}
    def parameters
      @parameters ||= lambda.parameters
    end

    sig {params(body: T.nilable(String)).returns(Proc)}
    def lambda(body = nil)
      line = File.read(@filename).split("\n")[@block.source_location.last - 1]

      match = /(do|{)\s*\|(?<params>[^|]+)\|/.match(line)
      return -> {} unless match

      param_source = T.must(match[:params])
      param_source += ', _: nil, __: nil, ___: nil' if body
      eval "-> (#{param_source}) { #{body} }"
    end
  end
end
