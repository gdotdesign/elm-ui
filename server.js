var app = require('koa')();
var sass = require('node-sass');
var serve = require('koa-static-folder');
var router = require('koa-router')();
var exec = require('child_process').exec;
var fs = require('fs')

/* Renders the CSS */
function renderCSS(callback){
  sass.render({
    file: './stylesheets/ui.scss',
  }, function(err, result) {
    callback(null, result.css)
  });
}

/* Renders the JS */
function renderElm(callback) {
  var cmd = 'elm-make source/kitchensink.elm --output test.js';

  exec(cmd, function(error, stdout, stderr) {
    callback(null, fs.readFileSync('test.js', 'utf-8'))
    fs.unlink('test.js')
  });
}

/* Serve HTML */
router.get('/', function *(next) {
  this.body = `<html>
                <head>
                  <title>Elm-UI Kitchesink</title>
                </head>
                <body>
                  <script src='index.js' type='application/javascript'>
                  </script>
                  <script>Elm.fullscreen(Elm.Main);</script>
                </body>
              </html>`
})

/* Serve JS */
router.get('/index.js', function *(next) {
  this.type = 'text/javascript';
  this.body = yield renderElm
})

/* Serve CSS */
router.get('/index.css', function *(next) {
  this.type = 'text/css';
  this.body = yield renderCSS
})

app
  .use(router.routes())

app.listen(8001);

console.log("Listening on localhost:8001")
