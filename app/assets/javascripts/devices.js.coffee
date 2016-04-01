#= require faye-authentication

$ ->
  return unless $('.show.admin_devices').length

  faye = new Faye.Client(fayeUrl)
  faye.addExtension(new FayeAuthentication(faye))

  channel = "/device/#{device.identifier}"

  log = $('#log')
  bottom = $('#bottom')

  append = (text) ->
    bottom.before("<div>#{text}</div>")
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
    if message.event in ['eval', 'print']
      append message[message.event]

  append("REPL -> #{channel} (#{device.name})")
