$ ->
  return unless $('.operations-rp15').length

  now = Math.floor(new Date().getTime() / 1000)

  $('.session').each (index, session) ->
    node = $(session)

    timeWindow = node.attr('data-timestamps')
    start = parseInt(timeWindow.split('-')[0])
    end   = parseInt(timeWindow.split('-')[1])

    delta = start - now
    setTimeout((-> node.addClass('now')), delta * 1000) if delta > 0
    delta = end - now
    setTimeout((-> node.removeClass('now')), delta * 1000) if delta > 0
    node.addClass('now') if start <= now and end > now

  # reload the page every 5 minutes
  #setTimeout (-> window.location.reload()), 1000 * 60 * 10

  # --- FUN ------------------------------------------------------------

  cornify = ->
    $.getScript 'http://www.cornify.com/js/cornify.js', ->
      cornify_add()
      $(document).click cornify_add
      alert 'Bored? Click for more unicorns!'

  ttu = Math.floor(new Date(2015, 4, 7, 16, 5).getTime() / 1000)
  delta = ttu - now
  console.log "Unicorns scheduled for in #{delta} seconds."
  setTimeout cornify, delta * 1000

  displayTTU = ->
    now     = Math.floor(new Date().getTime() / 1000)
    delta   = ttu - now
    hours   = Math.floor(delta / 3600)
    minutes = Math.floor((delta - (hours * 3600)) / 60)
    seconds = delta - (hours * 3600) - (minutes * 60)
    hours   = "0"+hours   if hours   < 10
    minutes = "0"+minutes if minutes < 10
    seconds = "0"+seconds if seconds < 10
    $('.ttu').text("TTU -#{hours}:#{minutes}:#{seconds}")

  setInterval displayTTU, 1000
