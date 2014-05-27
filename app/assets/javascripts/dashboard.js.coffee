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

    svg = d3.select('#notifications').append("svg")
    svg.attr("width", '100%').attr("height", maxY)
    maxX = svg[0][0].getBoundingClientRect().width

    update = (data) ->
      ids = (talk.id for talk in data)
      # console.log ids
      # console.log data
      scaleX = d3.scale.ordinal().domain(ids).rangePoints([0, maxX], 20)

      nodes = svg.selectAll('circle').data(data)
      nodes.attr('opacity', opacity)
      nodes.attr('style', (t) -> "fill: #{color(t)}")

      enter = nodes.enter()
      link = enter.append('a')
      link.attr('xlink:href', (t) -> t.pageurl)
      node = link.append('circle')
      node.attr('r', (t) -> 20)
      node.attr('cx', (t) -> scaleX(t.id))
      node.attr('cy', (t) -> 30)
      nodes.attr('style', (t) -> "fill: #{color(t)}")
          
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

    PrivatePub.subscribe "/notifications", (payload, channel) ->
      console.log "#{channel}: #{payload}"
      payload.id = parseInt(payload.name.match(/t(\d+)-/)[1])
      payload.age = 0
      return if payload.call == 'update_play'
      merge payload
      update talks

    PrivatePub.subscribe "/dj", (payload, channel) ->
      console.log "#{channel}: #{payload}"

    PrivatePub.subscribe "/event/talk", (payload, channel) ->
      console.log "#{channel}: #{payload}"
    
    PrivatePub.subscribe "/monitoring", (payload, channel) ->
      console.log "#{channel}: #{payload}"
      talk = payload.talk
      merge talk
      update talks
