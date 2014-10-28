require 'fidelity/console_logger'

module Fidelity
  class Exec < Struct.new(:file)

    class << self
      def run(args)
        file = args.shift
        new(file).run(ConsoleLogger.new)
      end
    end

    def run(logger)
      ChainRunner.new(file).run(logger)
    end

  end
end
