module Fidelity
  class Exec < Struct.new(:args)

    class << self
      def run(args, logger=nil)
        new(args).run(logger)
      end
    end

    def run(logger)
      ChainRunner.new(args).run(logger)
    end

  end
end
