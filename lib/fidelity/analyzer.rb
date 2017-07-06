module Fidelity
  class Analyzer < Struct.new(:manifestfile)

    def run(logger)
      errors = []

      path = File.dirname(manifestfile)
      logger.info "Analyzing files in '#{path}'"

      talk_start = manifest[:talk_start]
      talk_stop = manifest[:talk_stop]

      errors << 'talk_start missing in manifest' unless talk_start
      errors << 'talk_stop missing in manifest' unless talk_stop
      raise errors.join(', ') unless errors.empty?

      files = Dir.glob(path+'/*.flv').sort_by { |f| f.match(/t\d+-u\d+-(\d+)\.flv/)[1] }
      @file_len = files.map { |f| f.length }.max
      logger.debug header_format % %w(file user duration size flag start stop)
      files.each do |file|
        dur = duration(file)
        size = File.size(file)
        _, user, t0 = file.match(/t\d+-u(\d+)-(\d+)\.flv/).to_a.map { |c| c.to_i }
        tn = t0 + dur
        flag = nil
        flag = 'X' if dur == 0 and size > 0
        flag ||= '-' if size == 0
        flag ||= '*' unless tn < talk_start or t0 > talk_stop

        logger.debug line_format % [file, user, dur, size, flag, t0, tn]
      end
      logger.debug legend
    end

    private

    def legend
      <<-EOF

        Legend

        *  file is valid and lies (at least partialy) in live
        X  corrupted file
        -  file size is zero
      EOF
    end

    def header_format
      "%-#{@file_len}s %-7s %-7s %-9s %-1s %-9s %-9s"
    end

    def line_format
      "%-#{@file_len}s % 7d % 7d % 9d % 1s % 9d % 9d"
    end

    def duration(file)
      line = %x[ ffmpeg -i #{file} 2>&1 | grep Duration ]
      return 0 if line.empty?
      _, h, m, s = line.match(/(\d\d):(\d\d):(\d\d)/).to_a.map { |c| c.to_i }
      (h * 60 + m) * 60 + s
    end

    def manifest
      return @manifest unless @manifest.nil?
      path = File.expand_path(manifestfile, Dir.pwd)
      raise "Could not find file #{path}" unless File.exist?(path)
      @manifest = YAML.load(File.read(path))
    end

  end
end
