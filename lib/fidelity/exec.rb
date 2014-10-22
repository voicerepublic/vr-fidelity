module Fidelity
  class Exec < Struct.new(:args, :logger)

    class << self
      def run(args, logger)
        new(args, logger).run
      end
    end

    def run
      ChainRunner.new(args).run(logger)
    end

  end
end
