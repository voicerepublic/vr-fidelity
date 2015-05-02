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
