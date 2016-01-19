if Settings.errbit.enabled
  Airbrake.configure do |config|
    config.host = Settings.errbit.host
    config.project_id = true
    config.project_key = Settings.errbit.api_key
    config.ignore_environments = %w(development test)
  end
end
