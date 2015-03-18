require 'rails_helper'

RSpec.describe Talk, type: :model do

  it 'provides a method to import' do
    expect(Talk).to respond_to(:import)
  end

  it 'provides a decent regex for urls' do
    expect(Talk::URL_PATTERN).to match('http://voicerepublic.com')
    expect(Talk::URL_PATTERN).not_to match('http:/voicerepublic.com')
  end

end
