require 'spec_helper'

describe Fidelity::Strategy::M4a do

  it 'transcodes to m4a' do
    audio_fixture('spec/fixtures/complex', '1.wav') do |path|
      setting = Fidelity::Config.new(path)
      result = Fidelity::Strategy::M4a.call(setting)

      file = [path, result] * '/'
      assert { File.exist?(file) }
    end
  end

end
