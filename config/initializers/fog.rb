Storage = Fog::Storage.new(Settings.fog.storage.to_hash)

EC2 = Fog::Compute.new(Settings.fog.compute.to_hash)

EC2.instance_eval do
  def briefing
    servers.select { |s| s.ready? && s.tags['Target'] == Settings.target }
      .reduce({}) do |result, server|
      result.merge server.id => { name: server.tags['Name'],
                                  client_token: server.client_token,
                                  created_at: server.created_at,
                                  public_ip_address: server.public_ip_address }
    end
  end
end
