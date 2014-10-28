module Fidelity
  class Exec < Struct.new(:file)

    class << self
      def run(args)
        file = args.shift
        logger = Logger.new(STDOUT)
        logger.formatter = ->(sev, time, name, msg) do
          "#{msg}\n"
        end
        new(file).run(logger)
      end
    end

    def run(logger)
      ChainRunner.new(file).run(logger)
    end

  end
end
