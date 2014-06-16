# Endless Assimilation is like Continuous Integration, but more borg style.
#
class EndlessAssimilation < Struct.new(:app, :opts)
  
  PATTERN = /^\/ci$/

  def call(env)
    return app.call(env) unless env['REQUEST_METHOD'] == 'POST'
    return app.call(env) unless md = env['PATH_INFO'].match(PATTERN)

    data = JSON.parse(env['rack.input'].gets)
    Rails.logger.info(data.to_yaml)
    
    [ 200, {}, [] ]
  end
  
end
