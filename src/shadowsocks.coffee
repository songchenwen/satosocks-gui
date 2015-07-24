
gui = window.require 'nw.gui'
fs = require 'fs'
App = gui.App

platformMap =
  'win32': 'win'
  'darwin': 'osx'
  'linux': 'linux'

executablePath = "#{App.dataPath}/#{platformMap[process.platform]}/ss-local"
console.log "shadowsocks executable path #{executablePath}"

available = ->
  fs.existsSync executablePath

download = (callback)->
  

start = (config)->

exports.available = available
exports.start = start
exports.download = download
