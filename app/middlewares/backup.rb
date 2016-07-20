class Backup < Struct.new(:app, :opts)

  def call(env)
    return app.call(env) unless env['REQUEST_METHOD'] == 'GET'
    return app.call(env) unless env['PATH_INFO'] =~ %r{^/backup/(.+)$}

    # dump rack env (I left this here for future reference.)
    # File.open("/tmp/rack_env","w") { |f| PP.pp(env,f) }

    location = bucket.files.new(key: $1).url(5.minutes.from_now)

    [ 302, {'Location' => location}, [] ]
  end

  private

  def bucket
    @bucket ||= Storage.directories.get(bucket_name)
  end

  def bucket_name
    @bucket_name ||= Settings.storage.backup_recordings.split('@').first
  end

end
