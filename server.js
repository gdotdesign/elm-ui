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
function renderElm(str) {
  return function(callback) {
    var cmd = `elm-make '${str}' --output test.js`;
    exec(cmd, function(error, stdout, stderr) {
      if (stderr) {
        err = stderr.replace(/\n/g,"\\n")
                    .replace(/"/g, '\\"')
        callback(null, `console.error("${err}")`);
      } else {
        callback(null, fs.readFileSync('test.js', 'utf-8'))
        fs.unlink('test.js')
      }
    });
  }
}

function renderHtml(str) {
  return `<html>
      <head>
        <title>Elm-UI Kitchesink</title>
      </head>
      <body>
        <script src='${str}' type='application/javascript'>
        </script>
        <script>Elm.fullscreen(Elm.Main);</script>
      </body>
    </html>`
}

/* Serve HTML */
router.get('/', function *(next) {
  this.body = renderHtml('index.js')
})

/* Serve JS */
router.get('/index.js', function *(next) {
  this.type = 'text/javascript';
  this.body = yield renderElm('source/kitchensink.elm')
})

/* Serve CSS */
router.get('/index.css', function *(next) {
  this.type = 'text/css';
  this.body = yield renderCSS
})

 router.get('/_examples/:id', function *(next){
  this.type = 'text/javascript';
  this.body = yield renderElm(`examples/${this.params.id}/Main.elm`)
})

router.get('/examples/:id', function *(next){
  this.type = 'text/html'
  this.body = renderHtml(`/_examples/${this.params.id}`)
})

app
  .use(router.routes())

app.listen(8001);

console.log("Listening on localhost:8001")
