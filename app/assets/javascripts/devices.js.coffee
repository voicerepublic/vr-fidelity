#= require faye-authentication

$ ->
  return unless $('.show.admin_devices').length

  # --- faye setup

  faye = new Faye.Client(fayeUrl)
  faye.addExtension(new FayeAuthentication(faye))

  # --- repl

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

  append("Connecting to #{channel}...")
  faye.publish channel, event: 'handshake'

  # --- heartbeat

  faye.subscribe '/heartbeat', (message) ->
    if message.identifier == device.identifier
      $('tr.row-last_heartbeat_at td').html(new Date)

  # --- report

  faye.subscribe '/report', (message) ->
    if message.identifier == device.identifier
      $('#report').prepend("<div>#{JSON.stringify(message.report)}</div>")

  # --- debug log

  debuglog = $('#debuglog')

  prepend = (text) ->
    debuglog.prepend("<div>#{text}</div>")

  faye.subscribe "/device/log/#{device.identifier}", (message) ->
    prepend(message.log)
