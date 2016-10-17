# transcodes all dump_ files in the current directory to wav files
#
module Fidelity
  module Strategy
    class Wavify < Base

      class << self
        def required_executables
          %w( mplayer )
        end
      end

      def inputs
        e = Dir.new('.').entries.grep(/^dump_/)
        e - e.grep(/\.wav$/)
      end

      def run
        inputs.each do |file|
          transcode_any_to_wav(file)
        end
        outputs
      end

      def transcode_any_to_wav_cmd(name)
          "ffmpeg -n -loglevel panic -i %s %s.wav" %
          [ name, name ]
      end

      # will be checked as postcondition
      def outputs
        inputs.map { |f| f + '.wav' }
      end

    end
  end
end
