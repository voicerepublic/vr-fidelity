# Endless Assimilation is like Continuous Integration, but more borg style.
#
class EndlessAssimilation < Struct.new(:app, :opts)
  
  PATTERN = /^\/ci$/

  def call(env)
    return app.call(env) unless env['REQUEST_METHOD'] == 'POST'
    return app.call(env) unless md = env['PATH_INFO'].match(PATTERN)

    data = JSON.parse(env['rack.input'].gets)
    job = Assimilate.new(data)
    Delayed::Job.enqueue job, queue: 'ci'
    
    [ 200, {}, [] ]
  end
  
end
