# cuts the part given by `edit_config` from the given input file
#
module Fidelity
  module Strategy
    class Cut < Base

      def input
        "#{name}.wav"
      end

      def precut
        "#{name}-precut.mp3"
      end

      def convert_wav_to_mp3_cmd
        "lame --quiet #{input} #{precut}"
      end

      def tmpfile
        "#{name}-postcut.wav"
      end

      def cut_conf
        opts[:cut_conf]
      end

      def timecodes
        return ['0', '-0'] if cut_conf.blank?
        cut = cut_conf.map { |c| [c['start'], c['end']] }.flatten
        ["0"] + cut.map { |c| "=#{c}" } + ["-0"]
      end

      def cut_cmd
        "sox -V1 #{input} #{tmpfile} trim #{timecodes * ' '}; mv #{tmpfile} #{input}"
      end

      def run
        convert_wav_to_mp3
        cut
        input
      end

      def outputs
        [ input, precut ]
      end

    end
  end
end
