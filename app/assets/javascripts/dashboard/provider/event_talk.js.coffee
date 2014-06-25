# Example
#
# 
eventTalk = (callback) ->
  PrivatePub.subscribe "/event/talk", (payload, channel) ->
    console.log "#{channel}: #{JSON.stringify(payload)}"
    callback payload

window.provider.eventTalk = eventTalk
