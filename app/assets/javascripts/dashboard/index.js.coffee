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
  data = { talks: [], streams: [] }
  
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

  updateStreams = ->
    ;

  updateTalks = ->
    talks = data.talks
    ids = (talk.id for talk in talks)
    scaleX = d3.scale.ordinal().domain(ids).rangePoints([0, maxX], ids.length)
    states = ['prelive', 'live', 'postlive', 'processing', 'archived']
    scaleY = d3.scale.ordinal().domain(states).rangePoints([0, maxY], states.length)
    position = (d) ->
      "translate(#{scaleX(d.id)}, #{scaleY(d.state || 'prelive')})"

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
      .attr('r', (t) -> 20)
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

  provider.rtmpStat (streams) ->
    for stream_id, stream of streams
      data.streams.merge stream, stream_id
    updateStreams()
