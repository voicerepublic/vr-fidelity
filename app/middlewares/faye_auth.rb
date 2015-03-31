class FayeAuth < Struct.new(:app, :opts)

  def call(env)
    return app.call(env) unless env['REQUEST_METHOD'] == 'POST'
    return app.call(env) unless env['PATH_INFO'] == '/faye/auth'

    # dump rack env (I left this here for future reference.)
    # File.open("/tmp/rack_env","w") { |f| PP.pp(env,f) }

    req = Rack::Request.new(env)
    msgs = req.params['messages']

    resp = msgs.values.map do |msg|
      msg.merge signature: Faye::Authentication.sign(msg, opts[:secret])
    end

    [ 200, {}, [ { signatures: resp }.to_json ] ]
  end

end
