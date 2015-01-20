require 'spec_helper'

describe Fidelity::Strategy::Jinglize do

  it 'jinglizes' do
    audio_fixture('spec/fixtures/jinglize', '*.wav') do |path|
      setting = Fidelity::Config.new(path)
      setting.opts = {
        jingle_in: 'vr_start.wav',
        jingle_out: 'vr_stop.wav'
      }
      results = Fidelity::Strategy::Jinglize.call(setting)

      files = results.map { |result| [path, result] * '/' }
      assert { files.inject(true) { |a, file| a && File.exist?(file) } }
    end
  end

end
