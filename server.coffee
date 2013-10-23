http = require 'http'
path = require 'path'
stylus = require 'stylus'
request = require 'request'
express = require 'express'
cheerio = require 'cheerio'
identify = require 'identify'
poweredBy = require 'connect-powered-by'

app = express()
port = process.env.PORT or 4000
oneDay = 86400000
build = path.join __dirname, 'public'

# Middleware
app.set 'port', port
app.use express.compress()
app.use express.logger 'short'
app.use poweredBy()
app.use express.favicon()
app.use stylus.middleware build
app.use express.static build, maxAge: oneDay

# Routes
app.get '*', (req, res) ->
  url = "https://en.m.wikipedia.org#{req.path}"
  request uri: url, (err, response, body) ->
    res.send 500 if err
    $ = cheerio.load body
    $('head').append '<link rel="stylesheet" href="/main.css">'
    $('script').remove()
    res.send identify $.html(), anchor: true

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
