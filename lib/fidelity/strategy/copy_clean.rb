# Copies the current result files into a 'clean' namespace. But keeps a
# copy of the resulting wav file.
#
module Fidelity
  module Strategy
    class CopyClean < Base

      INFIX = 'clean'

      # finds files with result naming scheme
      def inputs
        @inputs ||= Dir.glob("#{name}.*") - [ "#{name}.journal" ]
      end

      def inputs_new_name
        inputs.map { |r| r.sub(/\.(\w+)$/, "-#{INFIX}.\\1") }
      end

      def resulting_wav_file
        "#{name}.wav"
      end

      def run
        inputs.each_with_index do |file, index|
          fu.cp(file, inputs_new_name[index])
        end
        outputs
      end

      # existence checked as postcondition
      def outputs
        inputs + inputs_new_name
      end

    end
  end
end
