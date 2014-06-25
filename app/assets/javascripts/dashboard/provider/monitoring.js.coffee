# Example
#
# { "event":"Archive",
#   "talk":{
#     "id":1054,
#     "title":"Lost & Found by Vitra",
#     "venue_id":242,
#     "starts_at":"2014-05-29T15:15:00.000+02:00",
#     "ends_at":"2014-05-29T15:45:00.000+02:00",
#     "ended_at":"2014-05-29T15:23:46.319+02:00",
#     "record":true,
#     "recording":"2014/05/29/1054",
#     "created_at":"2014-05-27T19:28:03.680+02:00",
#     "updated_at":"2014-05-29T15:24:24.061+02:00",
#     "teaser":"Talk by Flowers for Slovakia: ...",
#     "description":"<p>Open Talks Key Topic: ...</p>
#     "duration":30,
#     "image_uid":"2014/05/27/6osctbdwpa_DMY_Talks_pic1.png",
#     "session":{"7":{"id":7,"name":"Phil Hofmann","role":"participant",...
#
# { "event":"Processing",
#   "talk":{
#     "id":1054,
#     "run":"ogg",
#     "index":9,
#     "total":10
#   }
# }
monitoring = (callback) ->
  PrivatePub.subscribe "/monitoring", (payload, channel) ->
    console.log "#{channel}: #{JSON.stringify(payload)}"
    talk = payload.talk
    switch payload.event
      when 'StartTalk' then talk.state = 'live'
      when 'EndTalk'   then talk.state = 'postlive'
      when 'Process'   then talk.state = 'processing'
      when 'Archive'   then talk.state = 'archived'
    if talk.state == 'processing'
      talk.progress = payload.talk.index / payload.talk.total
      talk.task = payload.talk.run
    callback talk

window.provider.monitoring = monitoring

