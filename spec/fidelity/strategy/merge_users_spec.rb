require 'spec_helper'

describe Fidelity::Strategy::UserMerge do

  it 'merges by user' do
    # we need the wav fragments and the flvs (to reconstruct the journal)
    audio_fixture('spec/fixtures/complex', 't1-u*') do |path|
      setting = Fidelity::Config.new(path)
      results = Fidelity::Strategy::UserMerge.call(setting)

      files = results.map { |f| [ path, f ] * '/' }
      all_exist = files.inject(true) { |r, f| r && File.exist?(f) }
      assert { all_exist }
    end
  end

end
