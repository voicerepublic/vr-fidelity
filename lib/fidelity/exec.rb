require 'fidelity/console_logger'

module Fidelity
  class Exec < Struct.new(:file)

    class << self
      def run(args)
        cmd = args.shift
        file = args.shift
        new(file).send(cmd, ConsoleLogger.new)
      end
    end

    def run(logger)
      ChainRunner.new(file).run(logger)
    end

    def analyze(logger)
      Analyzer.new(file).run(logger)
    end

  end
end
