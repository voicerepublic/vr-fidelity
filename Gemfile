source 'https://rubygems.org'

gem 'rails', '4.0.2'
gem 'pg'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'haml-rails'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem "highcharts-rails", "~> 3.0.0"
gem 'd3_rails'
# remember to update app/assets/javascripts/private_pub.js when
# updating private_pub gem!
# see https://github.com/munen/voicerepublic_backoffice/commit/ca0b016e01481bd500
gem 'private_pub'

group :doc do
  gem 'sdoc', require: false
end

# gem 'bcrypt-ruby', '~> 3.1.2'

gem 'unicorn'
gem 'activeadmin', github: 'gregbell/active_admin'
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
  gem 'zeus'
  gem 'pry-rails'
  gem 'debugger'
  gem 'disable_assets_logger'
end
