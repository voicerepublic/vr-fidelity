# -*- mode: coffee -*-

# * "/notifications", # rtmp notify
# * "/monitoring",    # generic monitoring namespace (depr.)
# * "/dj",            # hooks in MonitoredJob
# * "/event/talk",    # state changes of talks
# * "/stat"           # rtmp stats

$ ->
  # namespace provider
  window.provider = {}

  faye = new Faye.Client(document.fayeUrl)
  faye.addExtension(new FayeAuthentication(faye))
  faye.addExtension(new FayeTtl(faye))

  subscribe = (namespace, handler) ->
    faye.subscribe namespace, (payload) ->
      console.log "#{namespace} #{JSON.stringify(payload)}"

      # extract the timestamp
      timestamp = null
      if payload.timestamp
        timestamp = payload.timestamp * 1000
        delete payload.timestamp
      timestamp ||= new Date().getTime()

      handler payload, timestamp

  # Example
  #
  # { "opts": { "id":1055 },
  #   "event": {
  #     "job": {
  #       "id":5098,
  #       "priority":20,
  #       "attempts":0,
  #       "handler":"--- !ruby/struct:Postprocess\nopts:\n  :id: 1055\n",
  #       "last_error":null,
  #       "run_at":"2014-05-29T15:25:08.667+02:00",
  #       "locked_at":"2014-05-29T15:25:09.437+02:00",
  #       "failed_at":null,
  #       "locked_by":
  #       "delayed_job.audio-0 host:voicerepublic-production pid:23560",
  #       "queue":"audio",
  #       "created_at":"2014-05-29T15:25:08.668+02:00",
  #       "updated_at":"2014-05-29T15:25:08.668+02:00"
  #     },
  #     "signal":"after"
  #   }
  # }
  #
  # Newer example for ns /dj
  #
  # {
  #   "job": {
  #     "id": null,
  #     "priority": 20,
  #     "attempts": 0,
  #     "handler": "--- !ruby/struct:EndTalk\nopts:\n  :id: 3438\n",
  #     "last_error":null,
  #     "run_at":"2015-03-23T13:43:45.352+01:00",
  #     "locked_at":null,"failed_at":null,
  #     "locked_by":null,
  #     "queue":"trigger",
  #     "created_at":null,
  #     "updated_at":null
  #   },
  #   "signal":"enqueue"
  # }
  #
  dj = (callback) ->
    subscribe "/dj", (payload, timestamp) ->
      return unless payload.job.queue == 'audio'
      callback payload.signal, timestamp

  window.provider.dj = dj

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
    subscribe "/notifications", (payload, timestamp) ->
      return if payload.call == 'update_play'

      [ _, talk, user ] = payload.name.match(/^t(\d+)-u(\d+)$/)
      payload.talk_id = talk
      payload.user_id = user

      payload.id = parseInt(talk)
      payload.age = 0

      callback payload, timestamp

  window.provider.rtmpNotify = rtmpNotify

  # Example
  #
  #     { "t68-u1": {
  #         "nclients":"2",
  #         "bw_in":"25080",
  #         "app_name":"record",
  #         "codec":"Speex" } }
  #
  rtmpStat = (callback) ->
    subscribe "/stat", (payload, timestamp) ->
      for id, stream of payload
        [ _, talk, user ] = id.match(/^t(\d+)-u(\d+)$/)
        payload[id].talk_id = talk
        payload[id].user_id = user
      callback payload, timestamp

  window.provider.rtmpStat = rtmpStat

  # Example
  #
  #
  eventTalk = (callback) ->
    subscribe "/event/talk", (payload, timestamp) ->
      callback payload, timestamp

  window.provider.eventTalk = eventTalk

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
    subscribe "/monitoring", (payload, timestamp) ->
      talk = payload.talk
      switch payload.event
        when 'StartTalk' then talk.state = 'live'
        when 'EndTalk'   then talk.state = 'postlive'
        when 'Process'   then talk.state = 'processing'
        when 'Archive'   then talk.state = 'archived'
      if talk.state == 'processing'
        talk.progress = payload.talk.index / payload.talk.total
        talk.task = payload.talk.run
      callback talk, timestamp

  window.provider.monitoring = monitoring
