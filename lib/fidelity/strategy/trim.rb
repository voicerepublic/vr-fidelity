# trims the resulting wav file to talk start and end
#
module Fidelity
  module Strategy
    class Trim < Base

      class << self
        def required_executables
          %w( sox )
        end
      end

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
        # ------------------------------ debug output
        talk_start = opts[:talk_start]
        talk_stop = opts[:talk_stop]

        [ ['Start Recording', file_start, fdt(file_start)],
          ['Start Signal', talk_start, fdt(talk_start)],
          ['Start Offset (Trim)', start, 'seconds'],
          ['Stop Signal', talk_stop, fdt(talk_stop)],
          ['Time between Signals', duration, 'seconds'],
          ['Recording Length', dur(backup), 'seconds']
        ].each do |info|
          puts '    %-20s % 20s % 30s' % info
        end
        # ------------------------------ end debug output

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

      private

      # format date time
      def fdt(timestamp)
        DateTime.strptime(timestamp.to_s,'%s')
      end

      def dur(file)
        line = %x[ avconv -i #{file} 2>&1 | grep Duration ]
        return 0 if line.empty?
        _, h, m, s = line.match(/(\d\d):(\d\d):(\d\d)/).to_a.map { |c| c.to_i }
        (h * 60 + m) * 60 + s
      end

    end
  end
end
