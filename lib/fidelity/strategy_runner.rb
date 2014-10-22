# The StrategyRunner's resposibility is to ensure a smooth process
# when running strategies. I will catch all errors and try to proceed.
#
module Audio
  class StrategyRunner < Struct.new(:setting)

    def run(strategy)
      if strategy.is_a?(String)
        name = "Audio::Strategy::#{strategy.camelize}"
        strategy = name.constantize
      end
      strategy.call(setting)
    rescue Exception => e
      setting.opts[:logfile].puts "# Error running strategy #{strategy}: #{e.message}"
      false
    end

  end
end
