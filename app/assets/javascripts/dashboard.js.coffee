$ ->
  if $('#livedashboard').length
    console.log 'init live dashboard'
    PrivatePub.subscribe "/monitoring", (data, channel) ->
      console.log data

# fayeExtension =
#   outgoing: (message, callback) ->
#     if message.channel == "/meta/subscribe"
#       message.ext ||= {}
#       message.ext.private_pub_signature = config.subscription.signature
#       message.ext.private_pub_timestamp = config.subscription.timestamp
#     callback message
# 
# $.getScript config.fayeClientUrl, (x) ->
#   client = new Faye.Client(config.fayeUrl)
#   client.addExtension(fayeExtension)
#   client.subscribe '/monitoring', (data) ->                      
#     console.log data
