module Fidelity
  class Exec < Struct.new(:args)

    class << self
      def run(args, logger=nil)
        file = args.unshift
        new(file).run(logger)
      end
    end

    def run(logger)
      ChainRunner.new(file).run(logger)
    end

  end
end
