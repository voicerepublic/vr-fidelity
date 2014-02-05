namespace :data do
  namespace :migrate do
    task create_admin: :environment do
      # TODO choose better default, could also move to seeds
      AdminUser.create!({
                          email: 'admin@example.com',
                          password: 'password',
                          password_confirmation: 'password'
                        })
    end
  end
end
