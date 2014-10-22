module Fidelity
  class Exec < Struct.new(:file)

    class << self
      def run(args, logger=nil)
        file = args.shift
        new(file).run(logger)
      end
    end

    def run(logger)
      path = File.dirname(file)
      base = File.basename(file)
      Dir.chdir(path) do
        ChainRunner.new(base).run(logger)
      end
    end

  end
end
