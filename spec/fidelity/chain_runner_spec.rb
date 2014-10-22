require 'spec_helper'

describe Fidelity::ChainRunner do
  it 'runs chains' do
    audio_fixture('spec/fixtures/complex', '*.{flv,yml}') do
      chain = %w( precursor kluuu_merge mp3 )
      Fidelity::ChainRunner.new(chain).run
    end
  end
end
