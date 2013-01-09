# Serial
sys = require("sys")
repl = require("repl")
serialPort = require("serialport").SerialPort

# Create new serialport pointer
serial = new serialPort "/dev/tty.usbmodem1d11" , baudrate: 9600

# Add data read event listener
serial.on "data", ( chunk ) ->
  sys.puts(chunk)

serial.on "error", ( msg ) ->
  sys.puts("SERIAL ERROR: " + msg )

repl.start( "=>" )


# Routes
routes = ->
  @get '/move/start': ->
    dir = parseInt @params["dir"]
    serial.write if dir > 0 then "F" else "B"

  @get '/move/stop': -> serial.write "s"

  @get '/claw/winch': ->
    val = parseInt @params["dir"]
    serial.write (if val == 1 then "p" else "P")

  @get '/claw/rotate': ->
    val = parseInt @params["dir"]
    serial.write (if val == 1 then "w" else "W")

  @get '/claw/claw': ->
    val = @params["claw"]
    buffer = new Buffer("c")
    buffer.writeInt8(if val == true then 1 else 0)
    serial.write buffer

  @get '/estop': -> serial.write "S"

  @get "/": ->
    [
      "routes:",
      "GET /",
      "GET /move/start FIELDS: dir (+1 or -1)",
      "GET /move/stop",
      "GET /claw/winch FIELDS: dir (+1 or -1)"
      "GET /claw/rotate FIELDS: dir (+1 or -1)"
      "GET /claw/claw FIELDS: claw (boolean)"
      "GET /estop",
    ].join("<br/>")


# Server config
port = if process.env.NODE_ENV is 'production' then 80 else 8082
require('zappajs') port, ->
  @use 'bodyParser'
  routes.call @
