require 'forwardable'
require 'cmd_runner'

# Each strategy defines a method `run`, which usually relies on the
# presence of one or more input files to produce one or more output
# files. If `input` (for a single file) or `inputs` (for a list of
# files) resp. `output` or `outputs` is defined, the presence of these
# files will be checked as a pre- resp. postcondition. If the
# condition is not met an error will be raised and the StrategyRunner
# will skip the strategy.
#
module Fidelity
  module Strategy
    class Base < Struct.new(:setting)

      extend Forwardable
      include CmdRunner

      class << self
        def required_executables
          []
        end

        def call(setting)
          result = nil
          path = setting.path
          instance = new(setting)
          instance.logger.info "run #{self.name}"

          instance.logger.debug "INPUT: #{instance.inputs.to_yaml }"
          precond = instance.inputs.inject(true) { |r, i| r && File.exist?(i) }
          raise "preconditions not met for #{name} " +
                "in #{path}: #{instance.inputs  * ', '}" unless precond

          result = instance.run

          instance.logger.debug "OUTPUT: #{instance.outputs.to_yaml}"
          postcond = instance.outputs.inject(true) { |r, i| r && File.exist?(i) }
          raise "postconditions not met for #{name} " +
                "in #{path}: #{instance.outputs * ', '}" unless postcond

          result
        end
      end

      def_delegators :setting, :name, :opts, :journal, :fragments, :users, :file_start

      def input
        nil
      end

      def inputs
        [ input ].compact
      end

      # returns result
      def run
        raise 'not implemented'
      end

      def output
        nil
      end

      def outputs
        [ output ].compact
      end

      def logger
        opts[:logger] || Logger.new('/dev/null')
      end

    end
  end
end
