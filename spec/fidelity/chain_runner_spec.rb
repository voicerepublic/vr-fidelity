require 'spec_helper'

describe Fidelity::ChainRunner do
  it 'runs chains' do
    audio_fixture('spec/fixtures/complex', '*.{flv,yml}') do
      Fidelity::ChainRunner.new('metadata.yml').run
    end
  end
end
