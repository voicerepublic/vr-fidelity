# Example
#
#     { "t68-u1": {
#         "nclients":"2",
#         "bw_in":"25080",
#         "app_name":"record",
#         "codec":"Speex" } }
# 
rtmpStat = (callback) ->
  PrivatePub.subscribe "/stat", (payload, channel, timestamp) ->

    timestamp = timestamp * 1000 unless timestamp == undefined
    timestamp ||= new Date().getTime()

    # console.log "#{channel}: #{timestamp} #{JSON.stringify(payload)}"
    for id, stream of payload
      [ _, talk, user ] = id.match(/^t(\d+)-u(\d+)$/)
      payload[id].talk_id = talk
      payload[id].user_id = user
    callback payload, timestamp

window.provider.rtmpStat = rtmpStat
