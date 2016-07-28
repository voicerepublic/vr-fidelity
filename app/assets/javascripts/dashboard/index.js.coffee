$ ->
  return unless $('#livedashboard').length

  # TODO fix these
  $('#active_admin_content').height('100%')
  $('#wrapper').height('80%')

  # ============================================================
  # setup data providers

  return unless Faye?
  faye = new Faye.Client(document.fayeUrl)
  faye.addExtension(new FayeAuthentication(faye))

  reports = {}
  faye.subscribe '/report', (device) ->
    key = device.identifier
    reports[key] = device
    console.log(reports)

  heartbeats = {}
  faye.subscribe '/heartbeat', (device) ->
    key = device.identifier
    heartbeats[key] = _.assign(device, time: new Date)
    console.log(heartbeats)

  connections = {}
  faye.subscribe '/admin/connections', (details) ->
    key = details.slug
    connections[key] = details
    # console.log(JSON.stringify(connections))

  stats = {}
  faye.subscribe '/admin/stats', (stat) ->
    key = stat.slug
    stats[key] ||= _.assign({}, stat, {stats: []})
    stats[key].stats.push(stat.stats)
    # console.log(JSON.stringify(stats))

  venues = {}
  faye.subscribe '/admin/venues', (snapshot) ->
    key = snapshot.venue.slug
    venues[key] ||= []
    venues[key].push(snapshot)
    # console.log(JSON.stringify(venues))

  talks = {}
  faye.subscribe '/admin/talks', (snapshot) ->
    key = snapshot.talk.slug
    talks[key] ||= []
    talks[key].push(snapshot)
    # console.log(JSON.stringify(talks))

  # ============================================================
  # setup d3

  svg = d3.select('#livedashboard').append("svg")
  svg.attr("width", '100%').attr("height", '100%')

  maxX = svg[0][0].getBoundingClientRect().width
  maxY = svg[0][0].getBoundingClientRect().height

  # --- setup svg layers
  svg.append('g').classed('devices', true)
  svg.append('g').classed('heartbeats', true)

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

  animDuration = 2000

  # ============================================================
  # d3 update


  updateDashboard = ->
    requestAnimationFrame updateDashboard

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

    # --- update reports
    reportKeys = _.keys(reports)
    reportNodes = svg.select('.reports')
      .selectAll('.report').data(reportKeys)
    reportNodes.enter().append('circle')
      .attr 'class', 'report'
      .attr 'fill',  '#ddd'
    reportNodes.transition().duration(animDuration)
      .attr 'cx', (d) -> maxX - 20
      .attr 'cy', (d) -> 100
      .attr 'r',  (d) -> 10


    heartbeatTimeout = (d) ->
      1 / ((new Date - heartbeats[d].time) / (heartbeats[d].interval * 1000))

    # --- update heartbeats
    heartbeatKeys = _.keys(heartbeats)
    heartbeatNodes = svg.select('.heartbeats')
      .selectAll('.heartbeat').data(heartbeatKeys)
    heartbeatNodes.enter().append('circle')
      .attr 'class', 'heartbeat'
      .attr 'fill',  'green'
    heartbeatNodes.transition().duration(animDuration)
      .attr 'cx', (d) -> maxX - 40
      .attr 'cy', (d) -> 50
      .attr 'r',  (d) -> heartbeatTimeout(d)
      .each (d) -> console.log(heartbeatTimeout(d))



  updateDashboard()







##    updateStreams = ->
##
##
##      # --- recalculate y scale
##      data.param = calculateParam()
##
##      # --- draw talks
##      talks = svg.select('.talks').selectAll('.talk').data(data.talks)
##      talks.enter().append('rect')
##        .attr('class', 'talk')
##        .attr('fill', '#ddd')
##        .attr('x', maxX/2)
##        .attr('width', 0)
##        #.each((d) -> console.log(JSON.stringify(d)))
##      talks.transition().duration(animDuration)
##        .attr('x', (d) -> timeScaleX(Date.parse(d.starts_at)))
##        .attr('width', (d) -> timeScaleX(Date.parse(d.ends_at)) -
##          timeScaleX(Date.parse(d.starts_at)))
##        .attr('y', (d) -> scaleY(d.id))
##        .attr('height', (d) -> elementHeight(d.id))
##
##      # --- draw fragments
##      fragments = svg.select('.fragments').selectAll('.fragment').data(data.fragments)
##      fragments.enter().append('rect').attr('class', 'fragment')
##        .attr('width', 0).attr('x', maxX/2)
##      fragments.transition().duration(animDuration)
##        .attr('x', (d) -> timeScaleX(d.start_time))
##        .attr('y', (d) -> scaleY(d.stream_id))
##        .attr('width', (d) -> timeScaleX(d.end_time) - timeScaleX(d.start_time))
##        .attr('height', (d) -> elementHeight(d.stream_id))
##        .attr('fill', (d) -> d.state)
##
##      # --- draw streams
##      streams = svg.select('.streams').selectAll('.stream').data(data.streams)
##      enter = streams.enter()
##        .append('g')
##          .attr('class', 'stream')
##          .attr('transform', (d) -> "translate(#{maxX/2+5}, #{scaleY(d.id)+4})")
##        .append('a')
##          # TODO fix link issue
##          .attr('xlink:href', (d) -> "//#{url}/talk/#{d.talk_id}")
##      enter.append('text').attr('x',   0).attr('class', 'nclients')
##      enter.append('text').attr('x',  70).attr('class', 'bandwidth')
##      enter.append('text').attr('x',  90).attr('class', 'codec')
##      enter.append('text').attr('x', 145).attr('class', 'id')
##      update = streams.transition().duration(animDuration)
##        .attr('transform', (d) -> "translate(#{maxX/2+5}, #{scaleY(d.id)+4})")
##      update.select('.nclients').text((d) -> d.nclients)
##      update.select('.bandwidth').text((d) -> "#{Math.round(d.bw_in/1024)} Kb/s")
##      update.select('.codec').text((d) -> d.codec)
##      update.select('.id').text((d) -> d.id)
##
##      # --- draw events
##      events = svg.selectAll('.event').data(data.events)
##      events.enter().append('path')
##        .attr('class', 'event')
##        .attr('d', eventMarker.top)
##        .attr('fill', eventColor)
##        .attr('transform', (d) -> "translate(#{maxX/2},#{scaleY(d.stream_id)})")
##      events.transition().duration(animDuration)
##        .attr('transform', (d) -> "translate(#{timeScaleX(d.timestamp)}," +
##          "#{scaleY(d.stream_id)})")
