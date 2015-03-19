require 'rails_helper'

RSpec.describe Admin::TalksController, type: :controller do
  login_admin_user

  it 'has an admin user logged in' do
    expect(subject.current_admin_user).not_to be_nil
  end
end
