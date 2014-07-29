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
  scaleY = d3.scale.ordinal()
    .rangePoints([0, maxY], 2)

  bwInColor = (d) ->
    return 'green' if d.value > 20000
    return 'orange' if d.value > 0
    'red'

  # --- misc helper functions
  descendingNclients = (a, b) ->
    d3.descending a.nclients, b.nclients

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
    scaleY.domain(data.streams.sort(descendingNclients).map (d) -> d.id)

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
      .attr('y', maxY/2)
      .attr('height', 20)

    # --- draw fragments
    fragments = svg.select('.fragments').selectAll('.fragment').data(data.fragments)
    fragments.enter().append('rect').attr('class', 'fragment')
      .attr('width', 0).attr('x', maxX/2)
    fragments.transition().duration(animDuration)
      .attr('x', (d) -> timeScaleX(d.start_time))
      .attr('y', (d) -> scaleY(d.stream_id))
      .attr('width', (d) -> timeScaleX(d.end_time) - timeScaleX(d.start_time))
      .attr('height', 10)
      .attr('fill', bwInColor)

    # --- draw streams
    streams = svg.select('.streams').selectAll('.stream').data(data.streams)
    streams.enter()
      .append('g')
        .attr('class', 'stream')
        .attr('transform', (d) -> "translate(#{maxX/2+5}, #{scaleY(d.id)+4})")
      .append('a')
        .attr('xlink:href', (d) -> "//#{url}/talk/#{d.talk_id}")
      .append('text')
    streams.transition().duration(animDuration)
      .attr('transform', (d) -> "translate(#{maxX/2+5}, #{scaleY(d.id)+4})")
      .select('text')
        .text((d) -> "#{d.id} #{d.bw_in.slice(-1)[0].value} Kb/s " +
          "(#{d.codec}) #{d.nclients}")

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

  provider.monitoring (talk) ->
    data.talks.merge talk

  provider.eventTalk (payload) ->
    ;

  # --- helper functions
  ascendingStartTime = (a, b) ->
    d3.ascending a.start_time, b.start_time

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
        indexOfLast = finding.bw_in.length - 1
        diff = (end_time - finding.bw_in[indexOfLast].end_time)
        same_bw = finding.bw_in[indexOfLast].value == stream.bw_in 
        if same_bw and diff <= delta + tolerance
          # console.log "EXTENDING FRAGMENT"
          finding.bw_in[indexOfLast].end_time = end_time
        else
          # console.log "NEW FRAGMENT"
          value = stream.bw_in
          finding.bw_in.push { start_time, end_time, value, stream_id }
        finding.nclients = stream.nclients
        finding.codec = stream.codec
      else
        # console.log "NEW STREAM"
        stream.id = stream_id
        value = stream.bw_in
        stream.bw_in = [ { start_time, end_time, value, stream_id } ]
        data.streams.push stream
    data.fragments = d3.merge(data.streams.map((s) -> s.bw_in))
    data.fragments = data.fragments.sort(ascendingStartTime)
    # console.log("FRAGMENTS: "+JSON.stringify(data.fragments))
    # console.log(JSON.stringify(data.streams))
    
