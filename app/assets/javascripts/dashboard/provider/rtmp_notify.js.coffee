# Example
#
# { "app":"record",
#   "flashver":"MAC 13,0,0,214",
#   "swfurl":"https://voicerepublic.com/assets/Blackbox6.swf",
#   "tcurl":"rtmp://voicerepublic.com/record",
#   "pageurl":"https://voicerepublic.com/venues/239/talks/1044",
#   "addr":"78.52.163.157",
#   "clientid":"4675",
#   "call":"update_publish",
#   "time":"2496",
#   "timestamp":"2497378",
#   "name":"t1044-u695650",
#   "id":1044,
#   "age":0 }
#
rtmpNotify = (callback) -> 
  PrivatePub.subscribe "/notifications", (payload, channel) ->
    console.log "#{channel}: #{JSON.stringify(payload)}"
    payload.id = parseInt(payload.name.match(/t(\d+)-/)[1])
    payload.age = 0
    return if payload.call == 'update_play'
    callback payload

window.provider.rtmpNotify = rtmpNotify

