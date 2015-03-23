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

dj = (callback) ->
  PrivatePub.subscribe "/dj", (payload, channel) ->
    console.log "#{channel}: #{JSON.stringify(payload)}"
    return unless payload.job.queue == 'audio'
    callback payload.signal

window.provider.dj = dj
