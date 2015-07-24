net = require 'net'

redir = (from, to) ->
  client = net.createServer {pauseOnConnect: true}, (socket) ->
    console.log "new connection #{client.connections}"

    server = net.connect {port: to, host:'127.0.0.1'}, ->
      socket.resume()

    server.on 'data', (data) -> socket.write(data) if socket
    socket.on 'data', (data) -> server.write(data) if server

    server.on 'close', (e) ->
      server = null
      if socket
        if e
          socket.destroy()
        else
          socket.end()

    socket.on 'close', (e) ->
      socket = null
      if server
        if e
          server.destroy()
        else
          server.end()
      console.log "connection close #{client.connections}"

  client.listen(from)

  return client

exports.redir = redir
