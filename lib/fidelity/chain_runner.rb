require 'yaml'
require 'logger'

# Runs chains of strategies by running StrategyRunner one at a time.
#
# You can inherit from this class to use the callbacks
#
# * before_chain
# * before_strategy(index, name)
# * after_strategy(index, name)
# * after_chain
#
module Fidelity
  class ChainRunner < Struct.new(:chain)

    attr_accessor :metadata

    def run(logger=nil)
      before_chain
      metadata[:logger] = logger || new_logger
      # TODO get rid of transitional code
      config = Config.new('.', metadata[:id], metadata)
      strategy_runner = StrategyRunner.new(config)
      chain.each_with_index do |name, index|
        before_strategy(index, name)
        strategy_runner.run(name)
        after_strategy(index, name)
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

    def metadata
      path = File.expand_path(Fidelity::METADATA_FILENAME, Dir.pwd)
      raise "Could not find file #{path}" unless File.exist?(path)
      @metadata ||= YAML.load(File.read(path))
    end

    def new_logger
      Logger.new(Fidelity::LOG_FILENAME)
    end

  end
end
