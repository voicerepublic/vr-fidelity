# config valid only for Capistrano 3.1
lock '3.1.0'

set :rbenv_type, :user
set :rbenv_ruby, '1.9.3-p448'
set :rbenv_ruby_version, "1.9.3-p448"

set :application, 'voicerepublic_backoffice'
set :repo_url, 'git@github.com:munen/voicerepublic_backoffice.git'

set :ssh_options, { forward_agent: true }

set :rails_env, "production"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/backend/app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/private_pub.yml config/settings.local.yml}

# Default value for linked_dirs is []
#set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{log tmp/pids public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :me, %x[whoami;hostname].split.join('@')

namespace :deploy do

  task :slack_started do
    slack "#{fetch(:me)} STARTED a deployment of "+
          "#{fetch(:application)} (#{fetch(:branch)}) to #{fetch(:stage)}"
  end
  after :started, :slack_started

  task :slack_finished do
    slack "#{fetch(:me)} FINISHED a deployment of "+
          "#{fetch(:application)} (#{fetch(:branch)}) to #{fetch(:stage)}"
  end
  after :finished, :slack_finished

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      execute "RAILS_ENV=#{fetch(:rails_env)} $HOME/bin/unicorn_wrapper restart"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

require 'json'

def slack(message)
  url = "https://voicerepublic.slack.com/services/hooks/incoming-webhook"+
        "?token=VtybT1KujQ6EKstsIEjfZ4AX"
  payload = {
    channel: '#voicerepublic_tech',
    username: 'capistrano',
    text: message,
    icon_emoji: ':floppy_disk:'
  }
  json = JSON.unparse(payload)
  cmd = "curl -X POST --data-urlencode 'payload=#{json}' '#{url}' 2>&1"
  %x[ #{cmd} ]
end
