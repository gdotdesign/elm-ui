var browserSync = require('browser-sync').create()
var serve = require('koa-static')
var koaRouter = require('koa-router')
var path = require('path')
var app = require('koa')()

var renderHtml = require('../render/html')
var renderElm = require('../render/elm')
var renderCSS = require('../render/css')

var readConfig = require('./read-config')

module.exports = function(options) {
  var config = readConfig(options)
  var router = new koaRouter({prefix: options.prefix})

  browserSync.watch("source/**/*.elm").on("change", browserSync.reload)

  browserSync.watch("stylesheets/**/*.scss", function(event, file) {
    if (event === "change") {
      browserSync.reload("*.css")
    }
  })

  browserSync.init({
    proxy: "localhost:8001",
    logFileChanges: false,
    reloadOnRestart: true,
    notify: false,
    open: false,
    port: 8002,
    ui: {
      port: 8003
    }
  })

  router.get('/', function*(next) {
    this.body = renderHtml()
  })

  router.get('/main.js', function*(next) {
    this.type = 'text/javascript'
    this.body = yield renderElm(path.resolve('source/Main.elm'), config)
  })

  router.get('/main.css', function*(next) {
    this.type = 'text/css'
    this.body = yield renderCSS(path.resolve('stylesheets/main.scss'))
  })

  app
    .use(router.routes())
    .use(serve(path.resolve('public')))

  app.listen(8001)

  console.log("Listening on localhost:8001")
}
