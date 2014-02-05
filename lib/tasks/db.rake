Rake::Task["db:migrate"].clear

namespace :db do
  task :migrate do
    readme = File.expand_path('../../../db/migrate/README.md', __FILE__)
    puts File.read(readme)
  end
end
