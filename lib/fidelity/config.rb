require 'null_logger'

# Fidelity::Config objects are data objects, with some logic for reading
# journals and coping with missing journals. Fidelity::Config is where the
# glue goes that connects the business logic of the talk model
# (app/models/talk) to the more generic audio processing stuff
# (lib/audio).
module Fidelity
  class Config

    attr_accessor :path, :name, :opts, :journal

    # for specs its handy to assume name is 1 and opts are empty
    def initialize(path, name=1, opts={})
      self.path = path
      self.name = name
      self.opts = opts

      self.opts[:logger] ||= NullLogger.new

      # this is done on instanciation to be able to rely on `Dir.pwd`
      self.journal = read_journal
    end

    def fragments
      e = Dir.new('.').entries.grep(/^dump_/)
      e -= e.grep(/\.wav$/) # but not wav
      e.map { |f| f.match(/^dump_(\d+)/).to_a }
    end

    # start of the first file that touches the live phase
    def file_start
      fragments.map { |f| f.last }.sort.first.to_i
    end

    private

    # uses avconv to determine duration of flv file in seconds
    def duration_of_flv(path)
      cmd = "avconv -i #{path} 2>&1 | grep Duration"
      output = %x[#{cmd}]
      _, h, m, s = output.match(/(\d+):(\d\d):(\d\d)/).to_a
      return 0 unless _
      s.to_i + 60 * (m.to_i + 60 * h.to_i)
    end

    # the content of the journal file might look like this:
    #
    #     publish asdf-1390839394.flv
    #     publish asdf-1390839657.flv
    #     publish asdf-1390898541.flv
    #     publish asdf-1390898704.flv
    #     record_done asdf-1390839394.flv 1390839394
    #     record_done asdf-1390839657.flv 1390839657
    #     record_done asdf-1390898541.flv 1390898541
    #     record_done asdf-1390898704.flv 1390898704
    #
    # then the journal will look like this
    #
    #     {"publish"=>
    #       [["asdf-1390839394.flv"],
    #        ["asdf-1390839657.flv"],
    #        ["asdf-1390898541.flv"],
    #        ["asdf-1390898704.flv"]],
    #       "record_done"=>
    #         [["asdf-1390839394.flv", "1390839394"],
    #          ["asdf-1390839657.flv", "1390839657"],
    #          ["asdf-1390898541.flv", "1390898541"],
    #          ["asdf-1390898704.flv", "1390898704"]]}
    def read_journal
      return @journal unless @journal.nil?
      check_journal!
      journal = File.read(journal_path)
      @journal = Hash.new { |h, k| h[k] = [] }.tap do |hash|
        journal.split("\n").each do |line|
          _, event, path, args = line.match(/^(\w+) ([.\w-]+) ?(.*)$/).to_a
          hash[event] << [path] + args.split if _
        end
      end
    end

    def journal_path
      "#{path}/#{name}.journal"
    end

    def check_journal!
      unless File.exist?(journal_path)
        write_fake_journal!
        opts[:logger].debug "! Journal #{journal_path} " +
                            "not found, reconstructed."
        opts[:logger].debug fake_journal
      end
    end

    def write_fake_journal!
      File.open(journal_path, 'w') { |f| f.puts fake_journal }
    end

    # contains implicit knowledge about naming scheme of files
    #
    # reconstructs a missing journal on the basis of that knowledge
    def fake_journal
      pattern = "#{path}/t#{name}-u*.flv"
      opts[:logger].debug "! searching for #{pattern}"
      flvs = Dir.glob(pattern).sort
      result = flvs.map do |flv|
        # skip it if it is an empty file
        next nil unless File.size(flv) > 0
        # skip it if it is a corrupt file
        next nil unless duration_of_flv(flv) > 0

        _, basename, timestamp = flv.match(/.*\/(.*?(\d+)\.flv)/).to_a
        ['record_done', basename, timestamp] * ' '
      end
      result.compact * "\n"
    end

  end

end