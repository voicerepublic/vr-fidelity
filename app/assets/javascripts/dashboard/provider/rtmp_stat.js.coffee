# Example
#
#     { "t68-u1": {
#         "nclients":"2",
#         "bw_in":"25080",
#         "app_name":"record",
#         "codec":"Speex" } }
# 
rtmpStat = (callback) ->
  PrivatePub.subscribe "/stat", (payload, channel) ->
    console.log "#{channel}: #{JSON.stringify(payload)}"
    for id, stream of payload
      [ _, talk, user ] = id.match(/^t(\d+)-u(\d+)$/)
      payload[id].talk_id = talk
      payload[id].user_id = user
    callback payload

window.provider.rtmpStat = rtmpStat
