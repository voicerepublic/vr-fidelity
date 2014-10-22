# transcodes all flv files to wav files
#
module Fidelity
  module Strategy
    class Precursor < Base

      def inputs
        journal['record_done'].map(&:first)
      end

      def run
        inputs.each do |file|
          transcode_flv_to_wav file.sub('.flv', '')
        end
        outputs
      end

      def transcode_flv_to_wav_cmd(name)
        "avconv -v quiet -y -i #{name}.flv -vn -ar 16k #{name}.wav"
      end

      # will be checked as postcondition
      def outputs
        inputs.map { |f| f.sub('.flv', '.wav') }
      end

    end
  end
end
