$ ->    
  return unless $('.index.admin_dashboard').length

  maxY = 333

  # --- initialize with no data
  data = { talks: [], streams: [], fragments: [], events: [] }
  
  # --- initialize once with seed data
  $.get '/admin/dashboard/seed', (d) ->
    $.extend data, d
    updateQueueSize()

  # --- setup url
  url = window.location.host
  url = url.replace('3001', '3000') # development
  url = url.replace(':444', '') # production

  # --- setup svg
  svg = d3.select('#livedashboard').append("svg")
  svg.attr("width", '100%').attr("height", maxY)
  maxX = svg[0][0].getBoundingClientRect().width

  # --- setup svg layers
  svg.append('g').classed('talks',     true)
  svg.append('g').classed('fragments', true)
  svg.append('g').classed('events',    true)
  svg.append('g').classed('streams',   true)

  # --- display queue size
  updateQueueSize = ->
    svg.select('.queue').text(data.djAudioQueueSize)

  svg.append('text')
    .attr('class', 'queue')
    .attr('x', 50)
    .attr('y', 30)
  updateQueueSize()

  # --- initialize time scale
  now     = new Date
  tplus4  = new Date(now.getTime() + 4 * 60 * 60 * 1000)
  tplus1  = new Date(now.getTime() + 1 * 60 * 60 * 1000)
  tminus1 = new Date(now.getTime() - 1 * 60 * 60 * 1000)
  tminus4 = new Date(now.getTime() - 4 * 60 * 60 * 1000)
  
  timeScaleX = d3.time.scale()
    .domain([tminus4, tminus1, tplus1, tplus4])
    .rangeRound([0, maxX/6, maxX/6*5, maxX])
  
  timeFormatter = d3.time.format('%H:%M')
  
  axisX = d3.svg.axis().scale(timeScaleX)
    .tickFormat(timeFormatter)
  
  svg.append('g').attr('class', 'axis').call(axisX)
  
  # --- set marker
  drawMarker = (x) ->
    svg.append('line')
      .attr('x1', x).attr('x2', x)
      .attr('y1', 0).attr('y2', maxY)
      .attr('class', 'marker')
  
  drawMarker Math.round(maxX/6)
  drawMarker Math.round(maxX/6*5)
  drawMarker Math.round(maxX/2)
  
  # --- clock
  preciseTimeFormatter = d3.time.format('%H:%M:%S')
  
  svg.append('text')
    .attr('class', 'now')
    .attr('text-anchor', 'middle')
    .attr('x', maxX/2)
    .attr('y', maxY - 10)
    .text(preciseTimeFormatter(now))

  # --- y scale
  # scaleY is a function that takes an id and returns the y
  scaleY = (d) -> data.param[d]?.y || 0

  elementHeight = (d) -> data.param[d]?.height || 20

  calculateParam = ->

    reduceStreams = (r, s) ->
      r[s.talk_id] ||= {}
      r[s.talk_id].streams ||= {}
      r[s.talk_id].streams[s.id] ||= {}
      r[s.talk_id].streams[s.id].nclients = s.nclients
      r
    talks = data.streams.reduce reduceStreams, {}

    # sum nclients
    for id, talk of talks
      talk.nclients = 0
      for i, s of talk.streams
        talk.nclients += s.nclients

    # descending sort order function generator
    descending = (property) ->
      (a, b) ->
        if property?
          a = a[property]
          b = b[property]
        return 1 if a < b
        return -1 if a > b
        0

    # set position by ranking
    rankedTalks = []
    for id, talk of talks
      rankedTalks.push [id, talk.nclients]
      #rankedStreams = []
      #for i, s of talk.streams
      #  rankedStreams.push [i, s.nclients]
      #rankedStreams = rankedStreams.sort descending(1)
      #for value, index in rankedStreams
      #  talk.streams[value[0]].position = index
    rankedTalks = rankedTalks.sort descending(1)
    for value, index in rankedTalks
      talks[value[0]].position = index

    # set y by walking data structure
    offset = 25
    gap = 5
    y = offset
    for rank in [0..Object.keys(talks).length]
      for id, talk of talks
        if talk.position == rank
          talk.y = y
          talk.height = gap
          y += gap
          for i, stream of talk.streams
            stream.y = y
            stream.height = 10
            total = stream.height + gap
            talk.height += total
            y += total
          y += gap

    # reduce to lookup hash
    result = {}
    for id, talk of talks
      result[id] = { y: talk.y, height: talk.height }
      for i, stream of talk.streams
        result[i] = { y: stream.y, height: stream.height }

    # return result
    result

  # state must be a color since it is also used to fill
  bwInState = (value) ->
    return 'green' if value > 20000
    return 'orange' if value > 0
    'red'

  # --- misc helper functions
  eventColor = (event) ->
    return 'green' if event.call == 'publish'
    return 'red'   if event.call == 'publish_done'
    'blue'

  animDuration = 500

  eventMarker =
    top:    'M0 0 L-3 -5 L3 -5 Z'
    bottom: 'M0 10 L3 15 L-3 15 Z'

  # --- update all
  updateStreams = ->

    # --- recalculate time scale
    now     = new Date
    tplus4  = new Date(now.getTime() + 4 * 60 * 60 * 1000)
    tplus1  = new Date(now.getTime() + 1 * 60 * 60 * 1000)
    tminus1 = new Date(now.getTime() - 1 * 60 * 60 * 1000)
    tminus4 = new Date(now.getTime() - 4 * 60 * 60 * 1000)
  
    timeScaleX.domain([tminus4, tminus1, tplus1, tplus4])
    svg.select('.axis').call(axisX)

    # --- update clock
    svg.select('.now').text(preciseTimeFormatter(now))

    # --- recalculate y scale
    data.param = calculateParam()

    # --- draw talks
    talks = svg.select('.talks').selectAll('.talk').data(data.talks)
    talks.enter().append('rect')
      .attr('class', 'talk')
      .attr('fill', '#ddd')
      .attr('x', maxX/2)
      .attr('width', 0)
      #.each((d) -> console.log(JSON.stringify(d)))
    talks.transition().duration(animDuration)
      .attr('x', (d) -> timeScaleX(Date.parse(d.starts_at)))
      .attr('width', (d) -> timeScaleX(Date.parse(d.ends_at)) -
        timeScaleX(Date.parse(d.starts_at)))
      .attr('y', (d) -> scaleY(d.id))
      .attr('height', (d) -> elementHeight(d.id))

    # --- draw fragments
    fragments = svg.select('.fragments').selectAll('.fragment').data(data.fragments)
    fragments.enter().append('rect').attr('class', 'fragment')
      .attr('width', 0).attr('x', maxX/2)
    fragments.transition().duration(animDuration)
      .attr('x', (d) -> timeScaleX(d.start_time))
      .attr('y', (d) -> scaleY(d.stream_id))
      .attr('width', (d) -> timeScaleX(d.end_time) - timeScaleX(d.start_time))
      .attr('height', (d) -> elementHeight(d.stream_id))
      .attr('fill', (d) -> d.state)

    # --- draw streams
    streams = svg.select('.streams').selectAll('.stream').data(data.streams)
    enter = streams.enter()
      .append('g')
        .attr('class', 'stream')
        .attr('transform', (d) -> "translate(#{maxX/2+5}, #{scaleY(d.id)+4})")
      .append('a')
        # TODO fix link issue
        .attr('xlink:href', (d) -> "//#{url}/talk/#{d.talk_id}")
    enter.append('text').attr('x',   0).attr('class', 'nclients')
    enter.append('text').attr('x',  70).attr('class', 'bandwidth')
    enter.append('text').attr('x',  90).attr('class', 'codec')
    enter.append('text').attr('x', 145).attr('class', 'id')
    update = streams.transition().duration(animDuration)
      .attr('transform', (d) -> "translate(#{maxX/2+5}, #{scaleY(d.id)+4})")
    update.select('.nclients').text((d) -> d.nclients)
    update.select('.bandwidth').text((d) -> "#{Math.round(d.bw_in/1024)} Kb/s")
    update.select('.codec').text((d) -> d.codec)
    update.select('.id').text((d) -> d.id)

    # --- draw events
    events = svg.selectAll('.event').data(data.events)
    events.enter().append('path')
      .attr('class', 'event')
      .attr('d', eventMarker.top)
      .attr('fill', eventColor)
      .attr('transform', (d) -> "translate(#{maxX/2},#{scaleY(d.stream_id)})")
    events.transition().duration(animDuration)
      .attr('transform', (d) -> "translate(#{timeScaleX(d.timestamp)}," +
        "#{scaleY(d.stream_id)})")

  # --- schedule updates
  setInterval updateStreams, 1000

  # ------------------------------------------------------------
  # --- setup providers
  # ------------------------------------------------------------

  provider.rtmpNotify (talk, timestamp) ->
    #console.log JSON.stringify(talk)
    return if talk.call == 'update_publish'
    # we track publish_done instead which is more generic
    return if talk.call == 'record_done' 

    stream_id = talk.name
    call = talk.call
    pos = 'top'
    data.events.push { timestamp, stream_id, call, pos }

  provider.dj (signal) ->
    switch signal
      when 'after' then data.djAudioQueueSize--
      when 'enqueue' then data.djAudioQueueSize++
    updateQueueSize()

  provider.monitoring (datum, timestamp) ->
    data.talks.merge datum

    #pos = 'bottom'
    #talk_id = datum.talk.id
    #call = datum.event
    #data.events.push { timestamp, talk_id, call, pos }

  provider.eventTalk (payload) ->
    ;

  # --- helper functions
  ascendingStartTime = (a, b) ->
    d3.ascending a.start_time+a.random, b.start_time+b.random

  # streams:
  #   - id: t687-t1
  #     nclients: "1"
  #     app_name: record
  #     codec: null
  #     talk_id: '687'
  #     user_id: '1'
  #     bw_in:
  #       - start_time: Mon Jul 28 2014 16:22:57 GMT+0200 (CEST)
  #         end_time:
  #         value: '1'
  #       - start_time: Mon Jul 28 2014 16:23:57 GMT+0200 (CEST)
  #         end_time:
  #         value: '1'
  provider.rtmpStat (streams, timestamp) ->
    delta = 4000
    tolerance = 1000
    lookup = {}
    lookup[stream.id] = stream for stream in data.streams
    for stream_id, stream of streams
      # console.log "STREAM: #{timestamp} #{stream_id} #{JSON.stringify(stream)}"
      start_time = timestamp
      end_time = timestamp + delta
      if finding = lookup[stream_id]
        indexOfLast = finding.fragments.length - 1
        diff = (end_time - finding.fragments[indexOfLast].end_time)
        same_bw = finding.fragments[indexOfLast].state == bwInState(stream.bw_in)
        if same_bw and diff <= delta + tolerance
          # console.log "EXTENDING FRAGMENT"
          finding.fragments[indexOfLast].end_time = end_time
        else
          # console.log "NEW FRAGMENT"
          state = bwInState(stream.bw_in)
          random = Math.random()
          finding.fragments.push { start_time, end_time, state, stream_id, random }
        finding.nclients = stream.nclients
        finding.codec = stream.codec
        finding.bw_in = stream.bw_in
      else
        # console.log "NEW STREAM"
        stream.id = stream_id
        state = bwInState(stream.bw_in)
        random = Math.random()
        stream.fragments = [ { start_time, end_time, state, stream_id, random } ]
        data.streams.push stream
    data.fragments = d3.merge(data.streams.map((s) -> s.fragments))
    data.fragments = data.fragments.sort(ascendingStartTime)
    # console.log("FRAGMENTS: "+JSON.stringify(data.fragments))
    # console.log(JSON.stringify(data.streams))
    
