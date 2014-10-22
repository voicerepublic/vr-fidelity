require 'spec_helper'

describe Fidelity::Strategy::TalkMerge do

  it 'merges by user then whole talk' do
    # we need the wav fragments and the flvs (to reconstruct the journal)
    audio_fixture('spec/fixtures/complex', 't1-u*') do |path|
      setting = Fidelity::Config.new(path)
      Fidelity::Strategy::UserMerge.call(setting)
      result = Fidelity::Strategy::TalkMerge.call(setting)

      file = [path, result] * '/'
      assert { File.exist?(file) }
    end
  end

end
