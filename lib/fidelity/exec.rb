require 'fidelity/console_logger'

module Fidelity
  class Exec < Struct.new(:args, :logger)

    class << self
      def run(args)
        cmd = args.shift
        new(args, ConsoleLogger.new).send(cmd)
      end
    end

    def run(manifest=source)
      ChainRunner.new(manifest).run(logger)
    end

    def analyze
      Analyzer.new(manifest).run(logger)
    end

    # fidelity process s3://vr-live-media/vr-2035
    def process
      logger.info "Pulling from #{source}"
      pull
      logger.info "Processing..."
      run manifest
      logger.info "Pushing to #{source}"
      push
    end

    private

    def pull
      # s3cmd sync s3://vr-live-media/vr-2035 .
      %x[ s3cmd -v sync #{source} . ]
    end

    def push
      # s3cmd sync vr-2035 s3://vr-live-media/vr-2035
      %x[ s3cmd --progress -v sync #{path} #{target} ]
    end

    def source
      args.first
    end

    def target
      "#{source}/"
    end

    def path
      args.first.split('/').last
    end

    def manifest
      Dir.glob("#{path}/*.yml").first
    end

  end
end
