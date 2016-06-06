var browserSync = require('browser-sync').create()
var serve = require('koa-static')
var koaRouter = require('koa-router')
var path = require('path')
var app = require('koa')()
var fs = require('fs')

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

  router.get('*', function*(next){
    var file = this.request.url.slice(1)
    var isJs = file.match(/\.js$/)
    var name = file.replace(/\.js$/, '')
    var filePath = path.resolve(`source/${name}.elm`)
    var haveElmFile = fs.existsSync(filePath)

    if(isJs && haveElmFile){
      this.type = 'text/javascript'
      this.body = yield renderElm(filePath, config)
    } else {
      yield next
    }
  })

  router.get('/main.css', function*(next) {
    this.type = 'text/css'
    this.body = yield renderCSS(path.resolve('stylesheets/main.scss'))
  })

  router.get('*', function*(next) {
    this.type = 'text/html'
    this.body = renderHtml(path.resolve('public/index.html'))
  })

  app
    .use(serve(path.resolve('public')))
    .use(router.routes())

  app.listen(8001)

  console.log("Listening on localhost:8001")
}
