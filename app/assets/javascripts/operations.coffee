$ ->
  return unless $('.operations-rp15').length

  offset = 3 * 24 * 60 * 60 + 4 * 60

  checkWhatsOn = ->
    now = Math.floor(new Date().getTime() / 1000) + offset
    console.log "check whats on #{new Date(now * 1000)}"

    $('.session').each (index, session) ->
      node = $(session)
      timeWindow = node.attr('data-timestamps')
      start = parseInt(timeWindow.split('-')[0])
      end   = parseInt(timeWindow.split('-')[1])
      if start <= now and end > now
        node.addClass('now')
      else
        node.removeClass('now')

  setInterval checkWhatsOn, 1000
