require 'rails_helper'

RSpec.describe Admin::SeriesController, type: :controller do
  login_admin_user

  it 'has an admin user logged in' do
    expect(subject.current_admin_user).not_to be_nil
  end

  it 'responds nicely' do
    get :index
    expect(response).to be_a_success
  end

  it 'responds nicely' do
    series = create(:series)
    get :show, id: series.id
    expect(response).to be_a_success
  end
end
