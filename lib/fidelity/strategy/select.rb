# select all the relevant files
#
module Fidelity
  module Strategy
    class Select < Base

      def inputs
        return @inputs unless @inputs.nil?

        # start with all `dump_` files
        files = Dir.new('.').entries.grep(/^dump_/)

        # remove wav files from the list (artifacts from previous runs)
        files -= files.grep(/\.wav$/)

        # extract timestamp from name
        files = files.map { |name| name.match(/^dump_(\d+)/).to_a }

        # sort oldest first
        files = files.sort_by(&:last)

        # limit to fragments during talk and the last before the talk
        during = files.select { |file| file.last.to_i >= manifest.talk_start }
        during = during.select { |file| file.last.to_i <= manifest.talk_stop }
        before = files.select { |file| file.last.to_i < manifest.talk_start }
        result = ([ before.last ] + during).compact

        # only names, discard timestamps
        result = result.map { |e| e.first }

        # remove empty files from the list
        @inputs = result.select { |f| File.size(f) > 0 }
      end

      def run
        # add the list of identified files to the manifest
        manifest.fragments = inputs
      end

      def outputs
        inputs
      end

    end
  end
end
