# trims the resulting wav file to talk start and end
#
module Fidelity
  module Strategy
    class Trim < Base

      def input
        "#{name}.wav"
      end

      def backup
        "#{name}-untrimmed.wav"
      end

      def make_backup_cmd
        "mv #{input} #{backup}"
      end

      def run
        make_backup
        trim
        input
      end

      def trim_cmd
        "sox -V1 #{backup} #{input} trim #{start} #{duration}"
      end

      # start may never return a negative value
      def start
        [ opts[:talk_start] - file_start, 0 ].max
      end

      def duration
        opts[:talk_stop] - opts[:talk_start]
      end

      def outputs
        [ input, backup ]
      end

    end
  end
end
