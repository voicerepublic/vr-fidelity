# runs the trimmed wav file thru auphonic and downloads all
# output files defined in the preset
#
module Fidelity
  module Strategy
    class Auphonic < Base

      def input
        "#{name}.wav"
      end

      def run
        # TODO: configure credentials via Settings
        preset = Auphonic::Preset.all.first
        production = preset.new_production
        production.save.upload(input).start
        sleep 10 until production.reload.status == 'Done'
        @outputs = production.download
      end

      def outputs
        @outputs
      end

    end
  end
end
