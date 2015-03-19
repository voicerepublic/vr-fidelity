require 'rails_helper'

RSpec.describe Admin::MetricsController, type: :controller do
  login_admin_user

  it 'has an admin user logged in' do
    expect(subject.current_admin_user).not_to be_nil
  end

  # FIXME
  skip 'responds nicely' do
    get :index
    expect(response).to be_a_success
  end

  it 'responds nicely' do
    metric = create(:metric)
    get :show, id: metric.id
    expect(response).to be_a_success
  end
end
