require 'date'

# merges all wav files into one based on timestamps
#
module Fidelity
  module Strategy
    class Merge < Base

      class << self
        def required_executables
          %w( sox cp )
        end
      end

      # all wave files
      def inputs
        Dir.new('.').entries.grep(/.wav$/)
      end

      def run
        merge_wavs(inputs, output)
        output
      end

      def output
        "#{name}.wav"
      end

      def merge_wavs_cmd(inputs, outfile)
        # cover edge cases
        raise 'no inputs?' if inputs.empty?
        if inputs.size == 1
          infile = inputs.first
          return "cp #{infile} #{outfile}"
        end

        # extract datetime
        inputs = inputs.map { |path| path.match(/dump_(\d+)\.wav/) }
        # parse datetime
        inputs = inputs.map { |path, time| [path, parse_ts(time)] }
        # sort by datetime
        inputs = inputs.sort_by { |_, datetime| datetime }
        # build command
        start_at = inputs.first[1]
        sox = "sox -V1 -m #{inputs.first[0]}"
        inputs[1..-1].each do |name, datetime|
          delay = ((datetime - start_at) * 24 * 60 * 60).to_i
          sox << " \"|sox -V1 #{name} -p pad #{delay}\""
        end
        sox << " #{outfile}"
      end

      def parse_ts(str)
        ::DateTime.strptime(str, '%s')
      end

    end
  end
end
