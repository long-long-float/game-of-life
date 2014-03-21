http = require 'http'
fs = require 'fs'

http.createServer (req, res) ->
  console.log 'starting server...'

  fs.readFile 'index.html', (err, content) ->
    throw err if err

    res.writeHead 200, { 'Content-Type': 'text/html', 'charset': 'utf-8' }
    res.end content
.listen 3000, 'localhost'

console.log 'listening...'