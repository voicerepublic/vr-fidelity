# The StrategyRunner's resposibility is to ensure a smooth process
# when running strategies. I will catch all errors and try to proceed.
#
module Fidelity
  class StrategyRunner < Struct.new(:setting)

    def run(strategy)
      if strategy.is_a?(String)
        strategy = Fidelity::Strategy.const_get(camelize(strategy))
      end
      strategy.call(setting)
    #rescue Exception => e
    #  setting.opts[:logger].info "# Error running strategy #{strategy}: #{e.message}"
    #  false
    end

    private

    def camelize(str)
      str.split('_').map { |s| s.capitalize }.join('')
    end

  end
end
