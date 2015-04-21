# this generates the visualization of the recordings of a talk
# on admin/talks#show
$ ->
  return unless $('.show.admin_talks').length

  # filter to entries which have a start
  data = window.data.filter (d) -> d.ext == '.flv' and d.start? and d.seconds > 0

  # find min and max
  t0 = (parseInt(d.start) for i, d of data)
  tn = (parseInt(d.start)+parseInt(d.seconds) for i, d of data)
  t0.push(startedAt)
  tn.push(endedAt)
  start = d3.min(t0)
  end = d3.max(tn)

  # extract users
  for d, i in data
    data[i].user = d.key.match(/t\d+-u(\d+)-\d+.flv/)[1]
  users = data.map (d) -> d.user
  users = d3.set(users).values() # unique

  # setup svg
  maxY = 5 + 10 * users.length + 5 + 10
  svg = d3.select('#visual').append('svg')
  svg.attr("width", '100%').attr("height", maxY)
  maxX = svg[0][0].getBoundingClientRect().width
  height = svg[0][0].getBoundingClientRect().height

  scaleX = d3.scale.linear().rangeRound([0, maxX])
  level = 'overview'

  switchLevel = ->
    if level == 'overview'
      level = 'detail'
      scaleX.domain([startedAt, endedAt])
    else
      level = 'overview'
      scaleX.domain([start, end])
    update()

  scaleY = d3.scale.ordinal().domain(users).rangePoints([5, 10 * users.length])

  widthF = (d) ->
    scaleX(parseInt(d.start) + parseInt(d.seconds)) - scaleX(parseInt(d.start))
  scaleC = d3.scale.category10().domain(users)
  colorF = (d) -> 'fill: ' + scaleC(d.user)

  update = ->
    # draw window
    sel = svg.selectAll('.window').data([{start: startedAt, end: endedAt}])
    sel.enter().append('rect')
    sel.transition().duration(1000)
      .attr('class', 'window')
      .attr('x', (d) -> scaleX(d.start))
      .attr('y', 5)
      .attr('width', (d) -> scaleX(d.end) - scaleX(d.start))
      .attr('height', height)
      .attr('style', 'fill: lightgrey')

    # draw overview
    sel = svg.selectAll('.overview').data(data)
    sel.enter().append('rect')
    sel.transition().duration(1000)
      .attr('class', 'overview')
      .attr('style', colorF)
      .attr('y', (d) -> 5 + scaleY(d.user))
      .attr('x', (d) -> scaleX(d.start))
      .attr('height', 10)
      .attr('width', widthF)
    console.log "update complete"


  svg.on("click", switchLevel)
  switchLevel()

  # # draw detail
  # svg.selectAll('.detail').data(data)
  #   .enter().append('rect')
  #   .attr('class', 'detail')
  #   .attr('style', 'fill: green')
  #   .attr('y', 25)
  #   .attr 'x', (d) -> scaleX(d.start)
  #   .attr('height', 10)
  #   .attr('width', widthF)

  if window.override
    svg.append('text')
      .attr('x', maxX-225)
      .attr('y', maxY-2)
      .attr('style', 'fill: red')
      .attr('font-size', '42px')
      .text('OVERRIDE')


  # TODO refactor out into it's own file social
  social = d3.select('#social')
  return unless social?
  (-> # wrap in immediate function
    margin = {top: 25, right: 5, bottom: 20, left: 25}

    main = social.attr("width", '100%').append("g")
      .attr("transform", "translate(#{margin.left},#{margin.top})")

    maxX = social[0][0].getBoundingClientRect().width
    maxY = social[0][0].getBoundingClientRect().height

    width  = maxX - margin.left - margin.right
    height = maxY - margin.top - margin.bottom

    x = d3.time.scale().range([0, width])
      .domain(d3.extent(listeners, (d) -> d.time))
    y = d3.scale.linear().range([0, height])
      .domain([d3.max(listeners, (d) -> d.count), 0])

    sxAxis = d3.svg.axis().scale(x).orient("bottom").ticks(0)
    syAxis = d3.svg.axis().scale(y).orient("left").ticks(1)

    valueline = d3.svg.line()
      .x((d) -> x(d.time))
      .y((d) -> y(d.count))

    main.append("path")
      .attr("class", "line")
      .attr("d", valueline(listeners));

    main.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,#{height})")
      .call(sxAxis)

    main.append("g")
      .attr("class", "y axis")
      .call(syAxis)
  )() # call immediate function
