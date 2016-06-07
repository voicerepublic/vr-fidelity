# provides a way to publish to an authenticated faye easily
#
#     Faye.publish_to('/some/channel', { some: 'data' })
#
module Faye
  def self.publish_to(channel, data)
    server, secret = Settings.faye.server, Settings.faye.secret_token
    Faye::Authentication::HTTPClient.publish(server, channel, data, secret)
  end
end
