require_relative 'file_context'
require_relative 'rule_context'
require_relative '../build_rule'
require_relative '../../error'

module Spud::BuildTools
  module SpudBuild
    class Rule < BuildRule
      def initialize(spud, file_context, name, files, deps, block)
        @spud = spud
        @file_context = file_context
        @name = name
        @files = files
        @deps = deps
        @block = block
      end

      def invoke(*args, **kwargs)
        raise Spud::Error, "'#{@name}' is up to date" if up_to_date?

        missing = required_params.length - args.length
        if missing > 0
          names = required_params.map { |name| "'#{name}'" }.join(', ')
          arguments = missing > 1 ? 'arguments' : 'argument'
          raise Spud::Error, "invocation of '#{@name}' missing required #{arguments} #{names}"
        end

        unless key_params?
          RuleContext.new(@spud, @file_context).instance_exec(*args, &@block)
          return
        end

        begin
          RuleContext.new(@spud, @file_context).instance_exec(*args, **kwargs, &@block)
        rescue ArgumentError => e
          raise Spud::Error, "invocation of '#{@name}' with #{e.message}"
        end
      end

      private

      # Up to date checking
      def up_to_date?
        return files_up_to_date? unless files_up_to_date?.nil?
        deps_up_to_date?
        #files_up_to_date? && deps_up_to_date?
      end

      def files_up_to_date?
        return nil if all_files.empty?
        all_files_exist?
      end

      def all_files_exist?
        all_files.all?(&File.method(:exist?))
      end

      def all_files
        @files.map(&Dir.method(:glob)).flatten
      end

      def deps_up_to_date?
        return nil if @deps.empty?

        @deps.all? do |deps, targets|
          targets = [targets].flatten
          deps = [deps].flatten

          latest_target = targets
            .map(&Dir.method(:glob))
            .flatten
            .map(&File.method(:mtime))
            .sort
            .last

          latest_dep = deps
            .map(&Dir.method(:glob))
            .flatten
            .map(&File.method(:mtime))
            .sort
            .last

          return false unless latest_target && latest_dep
          latest_target > latest_dep
        end
      end

      # Lambda
      def key_params?
        lam.parameters.map(&:first).include?(:key)
      end

      def required_params
        lam.parameters.select { |p| p.first == :req }.map(&:last)
      end

      def lam
        @lam ||= build_lam
      end

      def build_lam
        line = @block.source_location.last - 1
        line = File.read(filename).split("\n")[line]

        match = /(do|{)\s*\|(?<params>[^|]+)\|/.match(line)
        return -> {} unless match

        param_source = match[:params]
        eval("-> (#{param_source}) {}")
      end

      def filename
        'Spudfile'
      end
    end
  end
end
