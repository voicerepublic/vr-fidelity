# normalize all fragments
#
module Fidelity
  module Strategy
    class Normalize < Base

      def inputs
        fragments.map { |f| f.first.sub('.flv', '.wav') }
      end

      def run
        normalize_wavs inputs
        outputs
      end

      def outputs
        inputs
      end

      def tmpfile
        "#{name}-normalized.wav"
      end

      def normalize_wavs_cmd(files)
        raise 'no streams?' if files.empty?
        files.map do |file|
          "sox --norm #{file} #{tmpfile}; mv #{tmpfile} #{file}"
        end.join("\n")
      end

    end
  end
end
