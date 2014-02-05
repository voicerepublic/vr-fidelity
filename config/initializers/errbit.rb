Airbrake.configure do |config|
  config.api_key = 'a7c6435a7262e37062be690ef1af398b'
  config.host    = 'errbit.voicerepublic.com'
  config.port    = 80
  config.secure  = config.port == 443
end
