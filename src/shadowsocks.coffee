
fs = require 'fs'
request = require 'request'
mkdirp = require 'mkdirp'
cp = require 'child_process'
exec = cp.exec
redir = require './redir'
gui = window.require 'nw.gui'
App = gui.App


platformMap =
  'win32': 'win'
  'darwin': 'osx'
  'linux': 'linux'

platformPrefix = platformMap[process.platform]
executableDir = "#{App.dataPath}/#{platformPrefix}"
executablePath = "#{executableDir}/ss-local"
console.log "shadowsocks executable path #{executablePath}"

available = ->
  fs.existsSync executablePath

download = (callback)->
  url = "https://github.com/songchenwen/satosocks-gui/raw/binary/binary/#{platformPrefix}/ss-local"
  request({url: url, encoding: null, timeout:15000}, (error, res, body) ->
    if error
      console.log("download error: #{error}")
      callback(error)
    else
      mkdirp executableDir, (err)->
        if err
          console.log "make dir error #{err}"
          callback(err)
          return
        fs.writeFile(executablePath, body, {encoding: 'binary', mode: 555}, (error)->
          if error
            console.log("save error: #{error}")
            fs.unlinkSync(executablePath)
            callback(error)
          else
            console.log('download success')
            callback()
        )
  )
  
startShadow = (config)->
  exec "ss-local -s #{config.server} -p #{config.server_port} -k #{config.password} -m #{config.method} -l #{config.local_port} -v", {cwd: executableDir}, (err, stdout, stderr) ->
    console.log "#{err} \n\n #{stdout} \n\n #{stderr}"

start = (config)->
  redirPort = 65246
  listenPort = config.local_port
  config.local_port = redirPort
  r = {}
  r.shadowsocks = startShadow config
  r.redir = redir.redir(listenPort, redirPort)
  r.stop = ->
    @shadowsocks.kill()
    @redir.close()
  return r

exports.available = available
exports.start = start
exports.download = download
