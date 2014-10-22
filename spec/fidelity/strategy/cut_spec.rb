require 'spec_helper'

describe Fidelity::Strategy::Cut do

  it 'does not blow up when config for cut is omitted' do
    audio_fixture('spec/fixtures/talk_a', '1.wav') do |path|
      setting = Fidelity::Config.new(path)
      Fidelity::Strategy::Cut.call(setting)

      # NOTE: if this fails, you might need to install 'libsox-fmt-mp3'
      precut  = %x[ soxi -D 1-precut.mp3 ].to_i
      postcut = %x[ soxi -D 1.wav ].to_i
      assert { precut == postcut }
    end
  end

  it 'nicely cuts by edit_config' do
    audio_fixture('spec/fixtures/talk_a', '1.wav') do |path|
      # setup
      opts = { cut_conf: [ { 'start' => 1, 'end' => 2 },
                           { 'start' => 3, 'end' => 4 } ] }
      setting = Fidelity::Config.new(path, 1, opts)

      # run strategy
      Fidelity::Strategy::Cut.call(setting)

      # by size
      precut  = File.size('1-precut.mp3')
      postcut = File.size('1.wav')
      assert { precut < postcut }

      # by duration
      # NOTE: if this fails, you might need to install 'libsox-fmt-mp3'
      precut  = %x[ soxi -D 1-precut.mp3 ]
      postcut = %x[ soxi -D 1.wav ]
      assert { precut > postcut }
    end
  end

end
