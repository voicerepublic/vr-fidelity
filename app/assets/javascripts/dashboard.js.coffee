# Extending Array's prototype
unless Array::filter
  Array::filter = (callback) ->
    element for element in this when callback(element)

maxY = 300

# rects = null
# maxX = null
# nowX = null
# talks =
#   1:
#     id: 1
#     starts_at: '2014-05-07T00:30:00.000+02:00'
#     ends_at: '2014-05-07T01:30:00.000+02:00'
#     duration: 60
#   2:
#     id: 2
#     starts_at: '2014-05-07T01:00:00.000+02:00'
#     ends_at: '2014-05-07T01:30:00.000+02:00'
#     duration: 60
# 
# now = ->
#   new Date().getTime()
# 
# talkList = ->
#   talk for id, talk of talks
# 
# talkIds = ->
#   id for id, talk of talks
# 
# calculateS0 = (t) ->
#   start = Date.parse(t.starts_at)
#   s0 = (start - now()) / 1000
# 
# calculateE0 = (t) ->
#   end = Date.parse(t.ends_at)
#   e0 = (end - now()) / 1000
# 
# setup = ->
#   svg = d3.select('#livedashboard').append("svg")
#   svg.attr("width", '100%').attr("height", maxY)
#   maxX = svg[0][0].getBoundingClientRect().width
#   nowX = maxX / 2
# 
#   line = svg.append('line')
#   line.attr('x1', nowX).attr('x2', nowX)
#   line.attr('y1', 0).attr('y2', maxY)
#   line.attr('style', "stroke:#ccc;stroke-width:1")
# 
#   scaleX = d3.scale.linear().domain([-5400, 5400]).range([0, maxX])
#   scaleY = d3.scale.ordinal().domain(talkIds()).rangeBands([0, maxY])
# 
#   rects = svg.selectAll('rect')
#   enter = rects.data(talkList).enter()
#   rect = enter.append('rect')
#   rect.attr('height', 20)
#   rect.attr('width', (t) -> scaleX(calculateE0(t)) - scaleX(calculateS0(t)))
#   rect.attr('x', (t) -> scaleX(calculateS0(t)))
#   rect.attr('y', (t) -> scaleY(t.id))
#   rect.attr('opacity', 0.1)
# 
# update = (data, channel) ->
#   #console.log data unless console == undefined
#   talks[data.talk.id] = data.talk
#   #console.log talkList()
#   rects.data(talkList)
# 
# 
# $ ->
#   if $('#livedashboard').length
#     setup()
#     PrivatePub.subscribe "/monitoring", (data, channel) ->
#       console.log data
#       update(data, channel)

# --------------------------------------------------------------------------------

color = (talk) ->
  return 'violet' if talk.state == 'postlive'
  switch talk.call
    when 'update_publish'
      'green' 
    when 'over_due'
      'red' # no signal
    when 'publish'
      'blue' # just connected
    when 'record_done', 'publish_done'
      'yellow' # reload of page in progress or tab closed
    else
      'orange'

opacity = (talk) ->
  if talk.call in ['update_publish', 'publish']
    return (60 - talk.age) / 50 
  1
  
$ ->

  if $('#visual').length
    data = window.data.filter (d) -> d.start?
    t0 = (parseInt(d.start) for i, d of data)
    tn = (parseInt(d.start)+parseInt(d.seconds) for i, d of data)
    start = d3.min(t0)
    end = d3.max(tn)

    maxY = 15
    svg = d3.select('#visual').append('svg')
    svg.attr("width", '100%').attr("height", maxY)
    maxX = svg[0][0].getBoundingClientRect().width
    scaleX = d3.scale.linear().domain([start, end]).range([0, maxX])

    mark = (x) ->
      line = svg.append('line')
      line.attr('x1', x).attr('x2', x)
      line.attr('y1', 0).attr('y2', 15)
      line.attr('stroke', 'black').attr('stroke-width', 2)

    mark(scaleX(startedAt))
    mark(scaleX(endedAt))

    nodes = svg.selectAll('rect').data(data)
    nodes = nodes.enter().append('rect')
    nodes.attr('style', (d) -> "fill: green")
    nodes.attr('y', 5)
    nodes.attr 'x', (d) -> scaleX(d.start)
    nodes.attr('height', 10)
    nodes.attr 'width', (d) ->
      scaleX(parseInt(d.start) + parseInt(d.seconds)) - scaleX(parseInt(d.start))

  if $('#notifications').length

    url = window.location.host
    url = url.replace('3001', '3000')
    url = url.replace(':444', '')

    svg = d3.select('#notifications').append("svg")
    svg.attr("width", '100%').attr("height", maxY)
    maxX = svg[0][0].getBoundingClientRect().width

    # ---

    updateQueueSize = ->
      svg.select('.queue').text(djAudioQueueSize)

    svg.append('text')
      .attr('class', 'queue')
      .attr('x', 50)
      .attr('y', 30)
    updateQueueSize()

    # ---

    update = (data) ->
      ids = (talk.id for talk in data)
      scaleX = d3.scale.ordinal().domain(ids).rangePoints([0, maxX], ids.length)
      states = ['prelive', 'live', 'postlive', 'processing', 'archived']
      scaleY = d3.scale.ordinal().domain(states).rangePoints([0, maxY], states.length)
      position = (d) ->
        "translate(#{scaleX(d.id)}, #{scaleY(d.state || 'prelive')})"

      # --- data join
      nodes = svg.selectAll('.node').data(data)
      # --- update
      # --- enter
      link = nodes.enter().append('g').append('a')
        .attr('xlink:href', (t) -> "//#{url}/talk/#{t.id}")
      link.append('circle')
      link.append('text').text((t) -> "#{t.id}")
      # --- enter & update
      nodes.attr('class', 'node')
      nodes.transition().duration(500)
        .attr("transform", position)
      nodes.select('circle')
        .attr('r', (t) -> 20)
        .attr('style', (t) -> "fill: #{color(t)}")
        .attr('opacity', opacity)
      # --- exit
      nodes.exit().remove()
                                                
    tick = ->
      for index, talk of talks
        age = talks[index].age += 1
        talks[index].call = 'over_due' if age > 61
      update talks
            
    setInterval tick, 500

    merge = (talk) ->
      index = idx for idx, value of talks when value.id == talk.id
      if index then $.extend(talks[index], talk) else talks.push talk

    # --- handle messages

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
    PrivatePub.subscribe "/notifications", (payload, channel) ->
      console.log "#{channel}: #{JSON.stringify(payload)}"
      payload.id = parseInt(payload.name.match(/t(\d+)-/)[1])
      payload.age = 0
      return if payload.call == 'update_play'
      merge payload
      update talks

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
    PrivatePub.subscribe "/dj", (payload, channel) ->
      console.log "#{channel}: #{JSON.stringify(payload)}"
      if payload.event.job.queue == 'audio'
        switch payload.event.signal
          when 'after' then window.djAudioQueueSize--
          when 'enqueue' then window.djAudioQueueSize++
        updateQueueSize()

    # Example
    #
    # 
    PrivatePub.subscribe "/event/talk", (payload, channel) ->
      console.log "#{channel}: #{JSON.stringify(payload)}"

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
    PrivatePub.subscribe "/monitoring", (payload, channel) ->
      console.log "#{channel}: #{JSON.stringify(payload)}"
      talk = payload.talk
      switch payload.event
        when 'StartTalk' then talk.state = 'live'
        when 'EndTalk'   then talk.state = 'postlive'
        when 'Process'   then talk.state = 'processing'
        when 'Archive'   then talk.state = 'archived'
      merge talk
      update talks
