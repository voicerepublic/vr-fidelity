require 'spec_helper'

describe Fidelity::Strategy::Precursor do

  it 'prepares (running the precursor)' do
    audio_fixture('spec/fixtures/complex', '*.flv') do |path|
      setting = Fidelity::Config.new(path)
      results = Fidelity::Strategy::Precursor.call(setting)

      files = results.map { |f| [ path, f ] * '/' }
      all_exist = files.inject(true) { |r, f| r && File.exist?(f) }
      assert { all_exist }
    end
  end

end
