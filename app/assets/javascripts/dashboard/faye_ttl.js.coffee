window.FayeTtl = (client) ->

  incoming: (message, callback) ->
    if message.channel == '/meta/subscribe'
      # meta subscribe messages may carry cached messages
      if message.ext?.cached
        subscription = message.subscription
        # retrieve all registered handlers
        # TODO resolve tight coupling against implementation details
        handlers = client._channels._channels[subscription]._listeners.map (l) -> l[1]
        # fire timestamped events on the handler
        message.ext.cached.forEach((data) -> handler data) for handler in handlers
    # pass original meta subscribe message
    callback message
