#= require faye-authentication

$ ->
  return unless $('.show.admin_devices').length

  faye = new Faye.Client(fayeUrl)
  faye.addExtension(new FayeAuthentication(faye))

  $('#log').click ->
    $('#code').focus()

  channel = "/device/#{device.identifier}"

  log = $('#log')
  bottom = $('#bottom')

  append = (text) ->
    bottom.before($("<div>").text(text))
    log.scrollTop(log[0].scrollHeight)

  $('#code').keyup (event) ->
    if event.keyCode == 13
      code = $('#code').val()
      message =
        event: 'eval'
        eval: code
      faye.publish channel, message
      $('#code').val ''

  faye.subscribe channel, (message) ->
    event = message.event

    if event in ['eval', 'print']
      append message[event]

    if event is 'heartbeat'
      $('tr.row-last_heartbeat_at td').html(new Date)

    if event is 'report'
      $('#report').text(JSON.stringify(message.report))

  append("Connecting to #{channel}...")
  faye.publish channel, event: 'handshake'
