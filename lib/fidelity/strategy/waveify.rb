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

      # TODO check if `mplayer` is better than `avconv`
      def transcode_any_to_wav_cmd(name)
        "mplayer -quiet -vo null -vc dummy -demuxer +audio" +
          " -ao pcm:waveheader:file='%s.wav' '%s'" %
          [ name, name ]
      end

      # will be checked as postcondition
      def outputs
        inputs.map { |f| f + '.wav' }
      end

    end
  end
end
