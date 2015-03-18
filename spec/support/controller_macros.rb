module ControllerMacros
  def login_admin_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin_user]
      sign_in FactoryGirl.create(:admin_user) # Using factory girl as an example
    end
  end
end
