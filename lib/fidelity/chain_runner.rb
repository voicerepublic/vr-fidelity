require 'yaml'
require 'null_logger'
require 'ostruct'

# Runs chains of strategies by running StrategyRunner one at a time.
#
# You can inherit from this class to use the callbacks
#
# * before_chain
# * before_strategy(index, name)
# * after_strategy(index, name)
# * after_chain
#
# Then call it like this
#
#     ChainRunner.new(manifestfile).run(Logger.new)
#
module Fidelity
  class ChainRunner < Struct.new(:manifestfile)

    def run(logger=nil)
      before_chain
      raise 'No chain defined.' if chain.nil?
      manifest.chain = chain
      manifest.logger = logger || null_logger
      manifest.path = File.dirname(manifestfile)

      strategy_runner = StrategyRunner.new(manifest)
      manifest.logger.info "% cd #{manifest.path}"
      Dir.chdir(manifest.path) do
        chain.each_with_index do |name, index|
          before_strategy(index, name)
          strategy_runner.run(name)
          after_strategy(index, name)
        end
      end
      after_chain
    end

    private

    def before_chain
      # noop
    end

    def before_strategy(*args)
      # noop
    end

    def after_strategy(*args)
      # noop
    end

    def after_chain
      # noop
    end

    def chain
      return manifest.chain.split(/\s+/) if manifest.chain.is_a?(String)
      manifest.chain
    end

    def manifest
      return @manifest unless @manifest.nil?
      path = File.expand_path(manifestfile, Dir.pwd)
      raise "Could not find file #{path}" unless File.exist?(path)
      @manifest = OpenStruct.new(YAML.load(File.read(path)))
    end

    def null_logger
      NullLogger.new
    end

  end
end
