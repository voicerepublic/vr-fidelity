require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  login_admin_user

  it 'has an admin user logged in' do
    expect(subject.current_admin_user).not_to be_nil
  end

  it 'responds nicely' do
    get :index
    expect(response).to be_a_success
  end

  it 'responds nicely' do
    user = create(:user)
    get :show, id: user.id
    expect(response).to be_a_success
  end
end
