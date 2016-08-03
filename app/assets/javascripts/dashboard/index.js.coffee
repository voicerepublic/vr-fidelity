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

  # ============================================================
  # data

  debug = false

  events = [] # line, time, color
  reports = {}
  heartbeats = {}
  connections = {}
  stats = {}
  venues = {}
  talks = {}
  lines = {} # slug: slug, identifier: slug, ...

  # ============================================================
  # helpers

  addTalk = (snapshot, venueSlug=nil) ->
    #console.log 'ADD TALK', snapshot
    key = snapshot.id
    talks[key] = _.assign(snapshot, venue_slug: venueSlug)

  addVenue = (snapshot) ->
    #console.log 'ADD VENUE', snapshot
    key = snapshot.venue.slug
    venues[key] = snapshot
    _.each snapshot.venue.talks, (t) -> addTalk(t, key)
    lines[key] = key
    lines[mappings.devices[snapshot.venue.device_id]] = key

  # ============================================================
  # use briefings

  _.each briefings.venues, (venue) ->
    lines[venue.slug] = venue.slug
    lines[mappings.devices[venue.device_id]] = venue.slug if venue.device_id?

    venues[venue.slug] = {venue: venue}

    if venue.started_provisioning_at?
      events.push
        line: venue.slug
        time: venue.started_provisioning_at
        color: 'orange'
    if venue.completed_provisioning_at?
      events.push
        line: venue.slug
        time: venue.completed_provisioning_at
        color: 'lime'

  _.each briefings.servers, (server) ->
    lines[server.name] = server.name
    events.push
      line: server.name
      time: server.created_at
      color: 'magenta'
    venues[server.name] ||= {venue: {slug: server.name}}
    venues[server.name].venue.instance_id = server.instance_id
    console.log server
    console.log venues

  _.each briefings.talks, (talk) ->

    slug = mappings.venues[talk.venue_id]
    lines[slug] = slug

    addTalk(talk, slug)


  # ============================================================
  # subscribe

  faye.subscribe '/report', (device) ->
    console.log '/report', device if debug
    key = device.identifier
    reports[key] = _.assign(device, time: new Date)
    lines[key] ||= key

  faye.subscribe '/heartbeat', (device) ->
    console.log '/heartbeat', device if debug
    key = device.identifier
    heartbeats[key] = _.assign(device, time: new Date)
    lines[key] ||= key

  #faye.subscribe '/admin/connections', (details) ->
  #  key = details.slug
  #  connections[key] = details

  faye.subscribe '/admin/stats', (stat) ->
    console.log '/admin/stats', stat if debug
    key = stat.slug
    stats[key] = _.assign(stat, time: new Date, interval: 4)
    lines[key] = key

  faye.subscribe '/admin/venues', (snapshot) ->
    console.log '/admin/venues', snapshot if debug
    addVenue(snapshot)

  #faye.subscribe '/admin/talks', (snapshot) ->
  #  console.log snapshot
  #  key = snapshot.talk.slug
  #  #talks[key] ||= []
  #  #talks[key].push(snapshot)
  #  talks[key] = snapshot
  #  # console.log(JSON.stringify(talks))

  # ============================================================
  # setup d3

  svg = d3.select('#livedashboard').append("svg")
  svg.attr("width", '100%').attr("height", '100%')

  maxX = svg[0][0].getBoundingClientRect().width
  maxY = svg[0][0].getBoundingClientRect().height

  # --- setup svg layers
  svg.append('g').classed('lines', true)
  svg.append('g').classed('talks', true)
  svg.append('g').classed('connections', true)
  svg.append('g').classed('venues', true)
  svg.append('g').classed('reports', true)
  svg.append('g').classed('reportDetails', true)
  svg.append('g').classed('heartbeats', true)
  svg.append('g').classed('stats', true)
  svg.append('g').classed('statsDetails', true)
  svg.append('g').classed('identifiers', true)
  svg.append('g').classed('slugs', true)
  svg.append('g').classed('events', true)
  svg.append('g').classed('venue_device_names', true)
  svg.append('g').classed('venue_instance_ids', true)
  svg.append('g').classed('talk_names', true)

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


  # helpers
  heartbeatTimeout = (d, radius) ->
    since = new Date - d.time
    expected = d.interval * 1000
    ratio = 1 - since / expected
    if ratio >= 0
      ['lime', ratio * radius]
    else
      ['red', Math.min(radius, -ratio * radius)]

  venueColorByState =
    offline:             'SlateGray'
    available:           'Gold'
    provisioning:        'Chocolate'
    device_required:     'Fuchsia'
    awaiting_stream:     'Fuchsia'
    connected:           'Lime'
    disconnect_required: 'Fuchsia'
    disconnected:        'Red'

  talkColorByState =
    created:    'Red'
    pending:    'Fuchsia'
    prelive:    'Purple'
    live:       'Lime'
    postlive:   'Fuchsia'
    processing: 'OrangeRed'
    archived:   'RoyalBlue'
    suspended:  'Red'

  selectedVenues = {}

  toggleVenueSelection = (slug) ->
    selectedVenues[slug] = !selectedVenues[slug]

  opacityBySelection = (slug) ->
    if selectedVenues[slug] then 1 else 0

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

    # Y scale
    yScale = d3.scale.ordinal()
      .rangeRoundPoints([25, maxY-25], 0.5)
      .domain(_.uniq(_.values(lines)))

    # lines
    lineNodes = svg.select('.lines')
      .selectAll('.line').data(_.uniq(_.values(lines)))
    lineNodes.enter().append('line')
      .classed 'line', true
      .attr 'stroke-width', 1
      .attr 'stroke-opacity', 0.1
    lineNodes
      .attr 'x1', 0
      .attr 'y1', yScale
      .attr 'x2', maxX
      .attr 'y2', yScale

    # reports
    reportNodes = svg.select('.reports')
      .selectAll('.report').data(_.values(reports))
    reportNodes.enter().append('circle')
      .attr 'class', 'report'
      .attr 'stroke-opacity',  '0'
    reportNodes
      .attr 'cx',   (d) -> maxX - 80
      .attr 'cy',   (d) -> yScale(lines[d.identifier])
      .attr 'r',    (d) -> heartbeatTimeout(d, 20)[1]
      .attr 'fill', (d) -> heartbeatTimeout(d, 20)[0]

    # heartbeats
    heartbeatNodes = svg.select('.heartbeats')
      .selectAll('.heartbeat').data(_.values(heartbeats))
    heartbeatNodes.enter().append('circle')
      .attr 'class', 'heartbeat'
      .attr 'stroke-opacity', 0
    heartbeatNodes
      .attr 'cx',   (d) -> maxX - 40
      .attr 'cy',   (d) -> yScale(lines[d.identifier])
      .attr 'r',    (d) -> heartbeatTimeout(d, 20)[1]
      .attr 'fill', (d) -> heartbeatTimeout(d, 20)[0]

    # venues
    venueNodes = svg.select('.venues')
      .selectAll('.venue').data(_.values(venues))
    venueNodes.enter().append('circle')
      .attr 'class', 'venue'
      .on 'click', (d) -> toggleVenueSelection(d.venue.slug)
    venueNodes
      .attr 'stroke-opacity', (d) -> opacityBySelection(d.venue.slug)
      .attr 'cx',   (d) -> 40
      .attr 'cy',   (d) -> yScale(d.venue.slug)
      .attr 'r',    (d) -> 20
      .attr 'fill', (d) -> venueColorByState[d.venue.state] || 'white'

    # talks
    talkNodes = svg.select('.talks')
      .selectAll('.talk').data(_.values(talks))
    talkNodes.enter().append('rect')
      .attr 'class', 'talk'
      .attr 'fill-opacity', 0.2
      .attr 'stroke-opacity', 1
      .attr 'stroke-width', 1
    talkNodes
      .attr 'x',      (d) -> timeScaleX(Date.parse(d.starts_at))
      .attr 'y',      (d) -> yScale(d.venue_slug) - 20
      .attr 'width',  (d) -> (timeScaleX(Date.parse(d.ends_at)) -
                              timeScaleX(Date.parse(d.starts_at)))
      .attr 'height', (d) -> 40
      .attr 'stroke', (d) -> talkColorByState[d.state] || 'white'
      .attr 'fill',   (d) -> talkColorByState[d.state] || 'white'

    # talk names
    talkNodes = svg.select('.talk_names')
      .selectAll('.talk').data(_.values(talks))
      .attr 'x', (d) -> timeScaleX(Date.parse(d.starts_at)) + 5
      .attr 'y', (d) -> yScale(d.venue_slug) - 10
    talkNodes.enter().append('text')
      .classed 'talk', true
      .attr 'text-anchor', 'start'
      .attr 'opacity', 0.5
      .text (d) -> d.title

    # identifiers
    identifierNodes = svg.select('.identifiers')
      .selectAll('.identifier').data(_.values(heartbeats))
      .attr 'y', (d) -> yScale(lines[d.identifier]) + 10
    identifierNodes.enter().append('text')
      .classed 'identifier', true
      .attr 'text-anchor', 'middle'
      .attr 'opacity', 0.5
      .attr 'x', maxX - 60
      .text (d) -> d.identifier

    # device_name
    data = _.filter _.values(venues), (e) -> e.venue.device_name?
    identifierNodes = svg.select('.venue_device_names')
      .selectAll('.venue_device_name').data(data)
      .attr 'y', (d) -> yScale(lines[d.venue.slug]) - 10
    identifierNodes.enter().append('text')
      .classed 'venue_device_name', true
      .attr 'text-anchor', 'middle'
      .attr 'opacity', 0.5
      .attr 'x', maxX - 60
      .text (d) -> d.venue.device_name

    # instance_ids
    data = _.filter _.values(venues), (e) -> e.venue.instance_id?
    identifierNodes = svg.select('.venue_instance_ids')
      .selectAll('.venue_instance_id').data(data)
      .attr 'y', (d) -> yScale(lines[d.venue.slug]) + 10
    identifierNodes.enter().append('text')
      .classed 'venue_instance_id', true
      .attr 'text-anchor', 'middle'
      .attr 'opacity', 0.5
      .attr 'x', maxX/2 + 40
      .text (d) -> d.venue.instance_id

    # slugs
    slugNodes = svg.select('.slugs')
      .selectAll('.slug').data(_.uniq(_.values(lines)))
      .attr 'y', (d) -> yScale(d) + 10
    slugNodes.enter().append('text')
      .classed 'slug', true
      .attr 'text-anchor', 'start'
      .attr 'opacity', 0.5
      .attr 'x', maxX/2 + 80
      .text (d) -> d

    # stats
    statsNodes = svg.select('.stats').selectAll('.stat')
      .data _.values(stats)
      .attr 'cy',   (d) -> yScale(d.slug)
      .attr 'r',    (d) -> heartbeatTimeout(d, 20)[1]
      .attr 'fill', (d) -> heartbeatTimeout(d, 20)[0]
    statsNodes.enter().append('circle')
      .classed 'stat', true
      .attr 'cx',   (d) -> maxX/2 + 40
      .attr 'stroke-opacity', 0

    # stats details
    statsDetailNodes = svg.select('.statsDetails')
      .selectAll('.statsDetail').data(_.values(stats))
    statsDetailNodes.enter().append('text')
      .classed 'statsDetail', true
      .attr 'opacity', 0.5
      .attr 'text-anchor', 'middle'
      #.attr 'font-size', '150%'
      .attr 'x', maxX/2 + 40
    statsDetailNodes
      .attr 'y', (d) -> yScale(d.slug)
      .text (d) -> d.stats.listener_count

    # report details
    reportDetailNodes = svg.select('.reportDetails')
      .selectAll('.reportDetail').data(_.values(reports))
      .attr 'transform', (d) ->
        "translate(#{maxX - 200}, #{yScale(lines[d.identifier])+10})"
    enter = reportDetailNodes.enter().append('g')
      .classed 'reportDetail', true
      .attr 'opacity', 0.5
    enter.append('text').classed('temp', true)
    #enter.append('text').classed('mem', true)
    reportDetailNodes.select('.temp').text (d) -> d.report.temperature
    #reportDetailNodes.select('.mem').text (d) ->
    #  "#{d.report.memory.used}/#{d.report.memory.total}"


    # events
    eventNodes = svg.select('.events')
      .selectAll('.event').data(events)
      .attr 'cx', (d) -> timeScaleX(Date.parse(d.time))
      .attr 'cy', (d) -> yScale(d.line)
    eventNodes.enter().append('circle')
      .classed 'event', true
      .attr 'r', 10
      .attr 'fill', (d) -> d.color
      .attr 'opacity', 0.2
      .attr 'stroke-opacity', 0




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
