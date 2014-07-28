$ ->    
  return unless $('.index.admin_dashboard').length

  maxY = 300

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
        'white'
  
  opacity = (talk) ->
    if talk.call in ['update_publish', 'publish']
      return (60 - talk.age) / 50 
    1

  # initialize with no data
  data = { talks: [], streams: [], fragments: [] }
  
  # initialize once with seed data
  $.get '/admin/dashboard/seed', (d) ->
    $.extend data, d
    updateQueueSize()
    updateTalks()
    
  url = window.location.host
  url = url.replace('3001', '3000') # development
  url = url.replace(':444', '') # production

  svg = d3.select('#livedashboard').append("svg")
  svg.attr("width", '100%').attr("height", maxY)
  maxX = svg[0][0].getBoundingClientRect().width

  # ---

  updateQueueSize = ->
    svg.select('.queue').text(data.djAudioQueueSize)

  svg.append('text')
    .attr('class', 'queue')
    .attr('x', 50)
    .attr('y', 30)
  updateQueueSize()

  # ---
  # time scale updates every second

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
  
  drawMarker = (x) ->
    svg.append('line')
      .attr('x1', x).attr('x2', x)
      .attr('y1', 0).attr('y2', maxY)
      .attr('class', 'marker')
  
  drawMarker Math.round(maxX/6)
  drawMarker Math.round(maxX/6*5)
  drawMarker Math.round(maxX/2)
  
  preciseTimeFormatter = d3.time.format('%H:%M:%S')
  
  svg.append('text')
    .attr('class', 'now')
    .attr('text-anchor', 'middle')
    .attr('x', maxX/2)
    .attr('y', maxY - 10)
    .text(preciseTimeFormatter(now))

  scaleY = d3.scale.ordinal()
    .rangePoints([0, maxY])

  bwInColor = (d) ->
    return 'green' if d.value > 20000
    return 'orange' if d.value > 0
    'red'
      
  updateStreams = ->
    now     = new Date
    tplus4  = new Date(now.getTime() + 4 * 60 * 60 * 1000)
    tplus1  = new Date(now.getTime() + 1 * 60 * 60 * 1000)
    tminus1 = new Date(now.getTime() - 1 * 60 * 60 * 1000)
    tminus4 = new Date(now.getTime() - 4 * 60 * 60 * 1000)
  
    svg.select('.now').text(preciseTimeFormatter(now))
  
    timeScaleX.domain([tminus4, tminus1, tplus1, tplus4])
    svg.select('.axis').call(axisX)

    scaleY.domain(data.streams.map (d) -> d.id)

    fragments = svg.selectAll('.fragment').data(data.fragments)
    fragments.enter().append('rect').attr('class', 'fragment')
      .attr('width', 0).attr('x', maxX/2)
    fragments.transition().duration(750)
      .attr('x', (d) -> timeScaleX(d.start_time))
      .attr('y', (d) -> scaleY(d.stream_id))
      .attr('width', (d) -> timeScaleX(d.end_time) - timeScaleX(d.start_time))
      .attr('height', 10)
      .attr('fill', bwInColor)

    streams = svg.selectAll('.stream').data(data.streams)
    streams.enter().append('text')
      .attr('class', 'stream')
      .attr('x', (d) -> maxX/2 + 5)
    streams.transition().duration(750)
      .attr('y', (d) -> scaleY(d.id) + 4)
      .text((d) -> "#{d.id} #{d.bw_in.slice(-1)[0].value} Kb/s (#{d.codec}) #{d.nclients}")
      
  setInterval updateStreams, 1000

  # ---
  
  updateTalks = ->
    talks = data.talks
    ids = (talk.id for talk in talks)
    scaleX = d3.scale.ordinal().domain(ids).rangePoints([0, maxX], ids.length)
    states = ['prelive', 'live', 'postlive', 'processing', 'archived']
    scaleY = d3.scale.ordinal().domain(states).rangePoints([0, maxY], states.length)
    position = (d) ->
      "translate(#{scaleX(d.id)}, #{scaleY(d.state || 'prelive')+100})"

    # --- data join
    nodes = svg.selectAll('.node').data(talks)
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
      .attr('r', 20)
      .attr('style', (t) -> "fill: #{color(t)}")
      .attr('opacity', opacity)
    # --- exit
    nodes.exit().remove()
                                              
  tick = ->
    for index, talk of data.talks
      age = data.talks[index].age += 1
      data.talks[index].call = 'over_due' if age > 61
    updateTalks()
          
  setInterval tick, 500

  # --- setup providers

  provider.rtmpNotify (talk) ->
    data.talks.merge talk
    updateTalks()

  provider.dj (signal) ->
    switch signal
      when 'after' then data.djAudioQueueSize--
      when 'enqueue' then data.djAudioQueueSize++
    updateQueueSize()

  provider.monitoring (talk) ->
    data.talks.merge talk
    updateTalks()

  provider.eventTalk (payload) ->
    ;



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
    lookup = {}
    lookup[stream.id] = stream for stream in data.streams
    for stream_id, stream of streams
      # console.log "STREAM: #{timestamp} #{stream_id} #{JSON.stringify(stream)}"
      start_time = timestamp
      end_time = timestamp + 4000
      if finding = lookup[stream_id]
        indexOfLast = finding.bw_in.length - 1
        if finding.bw_in[indexOfLast].value == stream.bw_in
          console.log "EXTENDING FRAGMENT"
          finding.bw_in[indexOfLast].end_time = end_time
        else
          console.log "NEW FRAGMENT"
          value = stream.bw_in
          finding.bw_in.push { start_time, end_time, value, stream_id }
      else
        console.log "NEW STREAM"
        stream.id = stream_id
        value = stream.bw_in
        stream.bw_in = [ { start_time, end_time, value, stream_id } ]
        data.streams.push stream
    data.fragments = d3.merge(data.streams.map((s) -> s.bw_in))

    #console.log("FRAGMENTS: "+JSON.stringify(data.fragments))
    #console.log(JSON.stringify(data.streams))
    
