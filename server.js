var app = require('koa')();
var sass = require('node-sass');
var serve = require('koa-static-folder');
var router = require('koa-router')();
var exec = require('child_process').exec;
var fs = require('fs')

/* Renders the CSS */
function renderCSS(callback){
  sass.render({
    file: './stylesheets/main.scss',
  }, function(err, result) {
    if(err){
      callback(null, err.formatted)
    } else {
      callback(null, result.css)
    }
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

function renderHtml(title, str) {
  return `<html>
      <head>
        <title>${title}</title>
      </head>
      <body>
        <script src='${str}' type='application/javascript'>
        </script>
        <script>Elm.fullscreen(Elm.Main);</script>
      </body>
    </html>`
}

function renderIframe(title, id) {
  return `<html>
            <head>
              <title>${title}</title>
              <link rel="stylesheet" href="/index.css"/>
              <meta name="viewport" content="width=device-width, initial-scale=1">
            </head>
            <body class="mobile">
              <div>
                <iframe src='/html/${id}'></iframe>
              </div>
            </body>
          </html>`
}

router.get('/', function *(next) {
  this.body = renderHtml('Kitchensink','index.js')
})

router.get('/index.js', function *(next) {
  this.type = 'text/javascript';
  this.body = yield renderElm('source/kitchensink.elm')
})

router.get('/index.css', function *(next) {
  this.type = 'text/css';
  this.body = yield renderCSS
})

router.get('/html/:id', function *(next) {
  this.type = 'text/html'
  this.body = renderHtml(this.params.id, `/js/${this.params.id}`)
})

router.get('/js/:id', function *(next){
  this.type = 'text/javascript';
  this.body = yield renderElm(`examples/${this.params.id}/Main.elm`)
})

router.get('/examples/:id', function *(next){
  this.type = 'text/html'
  this.body = renderIframe(this.params.id, this.params.id)
})

app
  .use(router.routes())

app.listen(8001);

console.log("Listening on localhost:8001")
