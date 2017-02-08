require 'forwardable'
require 'cmd_runner'
require 'fileutils_logger'

# Each strategy defines a method `run`, which usually relies on the
# presence of one or more input files to produce one or more output
# files. If `input` (for a single file) or `inputs` (for a list of
# files) resp. `output` or `outputs` is defined, the presence of these
# files will be checked as a pre-/postcondition respectively. If the
# condition is not met an error will be raised and the StrategyRunner
# will halt the chain.
#
module Fidelity
  module Strategy
    class Base < Struct.new(:manifest)

      include CmdRunner

      class << self
        # strategies don't have any dependencies by default
        def required_executables
          []
        end

        def call(manifest)
          result = nil
          path = manifest.path
          instance = new(manifest)
          instance.logger.info "run #{self.name}"

          # check the preconditions
          instance.inputs.each do |input|
            instance.logger.debug "<< #{input}"
          end

          precond = instance.inputs.inject(true) { |r, i| r && File.exist?(i) }
          raise "preconditions not met for #{name} " +
                "in #{path}: #{instance.inputs  * ', '}" unless precond

          # run the strategy
          result = instance.run

          # check the postconditions
          instance.outputs.each do |output|
            instance.logger.debug ">> #{output}"
          end

          postcond = instance.outputs.inject(true) { |r, i| r && File.exist?(i) }
          raise "postconditions not met for #{name} " +
                "in #{path}: #{instance.outputs * ', '}" unless postcond

          result
        end
      end

      # this is a shortcut since many strategies use `name`
      def name
        manifest.id
      end

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
        manifest.logger || Logger.new('/dev/null')
      end

      def fu
        @fu ||= FileUtils.with_logger(LoggerWrapper.new(logger), :debug)
      end

      class LoggerWrapper < Struct.new(:logger)
        def debug(msg)
          logger.debug("% #{msg}")
        end
      end

    end
  end
end
