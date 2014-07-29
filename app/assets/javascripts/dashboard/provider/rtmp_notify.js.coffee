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
  PrivatePub.subscribe "/notifications", (payload, channel, timestamp) ->

    timestamp = timestamp * 1000 unless timestamp == undefined
    timestamp ||= new Date().getTime()
            
    # console.log "#{channel}: #{JSON.stringify(payload)}"
    return if payload.call == 'update_play'

    [ _, talk, user ] = payload.name.match(/^t(\d+)-u(\d+)$/)
    payload.talk_id = talk
    payload.user_id = user

    payload.id = parseInt(talk)
    payload.age = 0

    callback payload, timestamp

window.provider.rtmpNotify = rtmpNotify

