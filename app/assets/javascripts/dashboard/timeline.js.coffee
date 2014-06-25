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
