require 'spec_helper'

describe Fidelity::Strategy do

  it 'does not blow up when config for cut is omitted' do
    audio_fixture('spec/support/fixtures/talk_a', '1.wav') do |path|
      setting = Fidelity::Config.new(path)
      Fidelity::Strategy::Cut.call(setting)

      # NOTE: if this fails, you might need to install 'libsox-fmt-mp3'
      precut  = %x[ soxi -D 1-precut.mp3 ].to_i
      postcut = %x[ soxi -D 1.wav ].to_i
      expect(precut).to eq postcut
    end
  end

  it 'nicely cuts by edit_config' do
    audio_fixture('spec/support/fixtures/talk_a', '1.wav') do |path|
      # setup
      opts = { cut_conf: [ { 'start' => 1, 'end' => 2 },
                           { 'start' => 3, 'end' => 4 } ] }
      setting = Fidelity::Config.new(path, 1, opts)

      # run strategy
      Fidelity::Strategy::Cut.call(setting)

      # by size
      precut  = File.size('1-precut.mp3')
      postcut = File.size('1.wav')
      expect(precut).to be < postcut

      # by duration
      # NOTE: if this fails, you might need to install 'libsox-fmt-mp3'
      precut  = %x[ soxi -D 1-precut.mp3 ]
      postcut = %x[ soxi -D 1.wav ]
      expect(precut).to be > postcut
    end
  end

  it 'prepares (running the precursor)' do
    audio_fixture('spec/support/fixtures/complex', '*.flv') do |path|
      setting = Fidelity::Config.new(path)
      results = Fidelity::Strategy::Precursor.call(setting)

      files = results.map { |f| [ path, f ] * '/' }
      all_exist = files.inject(true) { |r, f| r && File.exist?(f) }
      expect(all_exist).to be_true
    end
  end

  it 'merges' do
    pending 'sampling rate issue'
    # we need the wav fragments and the flvs (to reconstruct the journal)
    audio_fixture('spec/support/fixtures/complex', 't1-u*') do |path|
      setting = Fidelity::Config.new(path)
      result = Fidelity::Strategy::KluuuMerge.call(setting)

      file = [path, result] * '/'
      expect(File.exist?(file)).to be_true
    end
  end

  it 'merges by user' do
    # we need the wav fragments and the flvs (to reconstruct the journal)
    audio_fixture('spec/support/fixtures/complex', 't1-u*') do |path|
      setting = Fidelity::Config.new(path)
      results = Fidelity::Strategy::UserMerge.call(setting)

      files = results.map { |f| [ path, f ] * '/' }
      all_exist = files.inject(true) { |r, f| r && File.exist?(f) }
      expect(all_exist).to be_true
    end
  end

  it 'merges by user then whole talk' do
    # we need the wav fragments and the flvs (to reconstruct the journal)
    audio_fixture('spec/support/fixtures/complex', 't1-u*') do |path|
      setting = Fidelity::Config.new(path)
      Fidelity::Strategy::UserMerge.call(setting)
      result = Fidelity::Strategy::TalkMerge.call(setting)

      file = [path, result] * '/'
      expect(File.exist?(file)).to be_true
    end
  end

  it 'trims' do
    # we need the wav and the journal
    audio_fixture('spec/support/fixtures/complex', '*') do |path|
      setting = Fidelity::Config.new(path)
      file_start = setting.journal['record_done'].first.last.to_i
      setting.opts = {
        file_start: file_start,
        talk_start: file_start + 3, # 3s later
        talk_stop:  file_start + 6 # 6s later
      }
      result = Fidelity::Strategy::Trim.call(setting)

      file = [path, result] * '/'
      expect(File.exist?(file)).to be_true
      cmd = "soxi -D #{file}"
      duration = %x[ #{cmd} ].to_f.round
      expect(duration).to eq(3)
    end
  end

  it 'transcodes to m4a' do
    audio_fixture('spec/support/fixtures/complex', '1.wav') do |path|
      setting = Fidelity::Config.new(path)
      result = Fidelity::Strategy::M4a.call(setting)

      file = [path, result] * '/'
      expect(File.exist?(file)).to be_true
    end
  end

  # it 'nicely merges streams' do
  #   fixture = 'spec/support/fixtures/talk_a'
  #   audio_fixture(fixture, 1) do |base, dir, name|
  #     # j = TalkAudio.new(base).journal
  #     # Audio::Merger.run(base, j)
  #     #
  #     # size_0 = File.size("#{fixture}/#{name}.wav")
  #     # size_1 = File.size("#{base}.wav")
  #     # expect(size_1).to be(size_0)
  #     #
  #     # # FIXME this doesn't work presumably because of meta data
  #     # #md5_0 = Digest::MD5.file("#{path}/#{name}.wav").hexdigest
  #     # #md5_1 = Digest::MD5.file("#{dir}/#{name}.wav").hexdigest
  #     # #expect(md5_1).to eq(md5_0)
  #   end
  # end
  #
  # it 'merges streams synchronously' do
  #   fixture = 'spec/support/fixtures/complex'
  #   audio_fixture(fixture, 't1-u*.flv') do |path|
  #     s = Fidelity::Config.new(path)
  #     Audio::Strategy::Precursor.call(s)
  #     p1 = Audio::Strategy::KluuuMerge.call(s)
  #
  #     p0 = "#{fixture}/1.wav"
  #     #c0 = open(p0, "rb") {|io| io.read }
  #     #c1 = open(p1, "rb") {|io| io.read }
  #
  #     #%x[ aplay #{p0} ]
  #     #%x[ aplay #{path}/#{p1} ]
  #
  #     # expect(c1).to eq(c0)
  #   end
  # end
  #
  # it 'nicly transcodes wav files' do
  #   # path, name = 'spec/support/fixtures/transcode0', 1
  #   # Dir.mktmpdir do |dir|
  #   #   FileUtils.cp(Dir.glob("#{path}/*.wav"), dir)
  #   #   Audio::Transcoder.run("#{dir}/#{name}")
  #   #   size_0 = File.size("#{path}/#{name}.m4a")
  #   #   size_1 = File.size("#{dir}/#{name}.m4a")
  #   #   expect(size_1).to be(size_0)
  #   # end
  # end

end
