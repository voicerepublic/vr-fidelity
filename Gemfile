source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.1'
gem 'haml-rails'
gem 'therubyracer', '0.12.0', platforms: :ruby
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'delayed_job', '~> 4.0.6'
gem 'delayed_job_active_record', '~> 4.0.3'
gem "highcharts-rails", "~> 3.0.0"
gem 'd3_rails'
# remember to update app/assets/javascripts/private_pub.js when
# updating private_pub gem!
# see https://github.com/munen/voicerepublic_backoffice/commit/ca0b016e01481bd500
gem 'private_pub'
gem 'devise'

gem 'sdoc', '~> 0.4.0', group: :doc

# optional
gem 'active_skin'


# gem 'bcrypt', '~> 3.1.7'

gem 'unicorn'
gem 'activeadmin', github: 'activeadmin/activeadmin'
gem 'airbrake'
gem 'rails_config'
gem 'activeadmin-dragonfly', github: 'stefanoverna/activeadmin-dragonfly'
gem 'acts-as-taggable-on', '3.0.1' # tag-system

group :development do
  gem 'annotator'
  gem 'capistrano',         '~> 3.1.0'
  gem 'capistrano-rbenv',   '~> 2.0.1'
  gem 'capistrano-bundler', '~> 1.1.1'
  gem 'capistrano-rails',   '~> 1.1.1'
end

group :development, :test do
  gem 'spring'
  gem 'web-console', '~> 2.0'
  gem 'pry-rails'
  gem 'byebug'
  #gem 'disable_assets_logger'

  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'spring-commands-rspec' # TODO check if needed
  gem 'rack-test'
  gem 'factory_girl_rails'
end
