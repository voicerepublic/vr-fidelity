# trims the resulting wav file to talk start and end
#
module Fidelity
  module Strategy
    class Trim < Base

      class << self
        def required_executables
          %w( sox ffmpeg )
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

      def file_start
        manifest.fragments.map { |f| f.match(/\d+/)[0] }.sort.first.to_i
      end

      def audit
        [ ['Start Recording', file_start, fdt(file_start)],
          ['Start Signal', manifest.talk_start, fdt(manifest.talk_start)],
          ['Start Offset (Trim)', start, 'seconds'],
          ['Stop Signal', manifest.talk_stop, fdt(manifest.talk_stop)],
          ['Time between Signals', duration, 'seconds'],
          ['Recording Length', dur(backup), 'seconds']
        ].each do |info|
          puts '    %-20s % 20s % 30s' % info
        end
      end

      def run
        make_backup
        audit # for debugging only
        trim
        input
      end

      def trim_cmd
        "sox -V1 #{backup} #{input} trim #{start} #{duration}"
      end

      # start may never return a negative value
      def start
        [ manifest.talk_start - file_start, 0 ].max
      end

      def duration
        manifest.talk_stop - manifest.talk_start
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
        line = %x[ ffmpeg -i #{file} 2>&1 | grep Duration ]
        return 0 if line.empty?
        _, h, m, s = line.match(/(\d\d):(\d\d):(\d\d)/).to_a.map { |c| c.to_i }
        (h * 60 + m) * 60 + s
      end

    end
  end
end
