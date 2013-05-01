root = exports ? window
root.Swagr = if root.Swagr then root.Swagr else {}

# Handle a websocket connection to the server at a given mount point.
class root.Swagr.Websocket
  constructor: (ipAddress = "0.0.0.0", portNumber = "3000", mountPoint = "websocket") ->
    @ip_address = ipAddress
    @port_number = portNumber
    @mount_point = mountPoint
    @connected = false
    @connect_to_mount_point()

  connect_to_mount_point: () ->
    @ws = new WebSocket("ws://" + @ip_address + ":" + @port_number + "/" + @mount_point)
    @ws.onopen = @onopen
    @ws.onclose = @onerror
    @ws.onmessage = @onmessage

  onopen: () ->
    console.log("Websocket connection is UP.") unless @connected
    @connected = true
    # Send a greeting message to the server.
    @send "Hello Server!"

  send: (msg) ->
    @ws.send(msg);
    console.log("Sent to server: " + msg)

  onclose: () ->
    if @connected == true
      console.log("Websocket connection is DOWN.")
    else
      console.log(".")
    @connected = false
    # We will try to reconnect every second
    setTimeout 1000, @connect_to_mount_point

  onmessage: (e) ->
    msg = e.data;
    console.log "Received message: " + msg

if window.WebSocket
  # Announce that the browser does support web sockets.
  console.log 'Websocket is supported by this browser!'

  # Initial connection attempt to the web socket app.
  root.websocket = new root.Swagr.Websocket
else
  # WebSockets are not supported by this browser. Either fall back to alternate method or display error page.
  console.log "Web sockets are not supported by this browser :("