var autoprefixer = require('autoprefixer');
var exec = require('child_process').exec;
var uglifyJS = require("uglify-js");
var cleanCSS = require('clean-css');
var sass = require('node-sass');
var async = require('async');
var path = require('path');
var fs = require('fs');

var elmExecutable =
  path.resolve(__dirname, '../node_modules/elm/binwrappers/elm-make');

exports.serve = function(options){
  var router = require('koa-router')();
  var serve = require('koa-static');
  var app = require('koa')();

  router.get('/', function *(next) {
    this.body = renderHtml('main.js')
  })

  router.get('/main.js', function *(next) {
    this.type = 'text/javascript';
    this.body = yield renderElm(options.elm)
  })

  router.get('/main.css', function *(next) {
    this.type = 'text/css';
    this.body = yield renderCSS(options.css)
  })

  app
    .use(router.routes())
    .use(serve(options.public));

  app.listen(8001);

  console.log("Listening on localhost:8001")
}

renderCSS = function(file){
  return function(callback) {
    sass.render({
      file: file,
    }, function(err, result) {
      if(err){
        callback(err.formatted, null)
      } else {
        autoprefixer
          .process(result.css)
          .then(function(result2){
            callback(null, result2.css)
          })
      }
    });
  }
}

renderElm = function(file) {
  return function(callback) {
    var cmd = `${elmExecutable} '${file}' --output test.js`;
    exec(cmd, function(error, stdout, stderr) {
      if (stderr) {
        err = stderr.replace(/\n/g,"\\n")
                    .replace(/"/g, '\\"')
        callback(null, `document.write("${err}")`);
      } else {
        callback(null, fs.readFileSync('test.js', 'utf-8'))
        fs.unlink('test.js')
      }
    });
  }
}

renderHtml = function(str) {
  return `<html>
      <head>
      </head>
      <body style="overflow: hidden;margin:0;">
        <script src='${str}' type='application/javascript'>
        </script>
        <script>Elm.fullscreen(Elm.Main);</script>
      </body>
    </html>`
}

buildElm = function(source, dest){
  return function(callback){
    console.log('Building JS...')
    renderElm(source)(function(err, contents){
      if(err) { return callback(err, null) }
      minified = uglifyJS.minify(contents, {fromString: true});
      fs.writeFileSync(dest, minified.code)
      callback(null, null);
    })
  }
}

buildHtml = function(str, dest) {
  return function(callback){
    console.log('Building HTML...')
    var html = renderHtml(str)
    fs.writeFileSync(dest, html)
    callback(null, null);
  }
}

buildCSS = function(source, dest){
  return function(callback){
    console.log('Building CSS...')
    renderCSS(source)(function(err, contents){
      if(err) { return callback(err, null) }
      minified = new cleanCSS().minify(contents)
      fs.writeFileSync(dest, minified.styles)
      callback(null, null);
    })
  }
}

exports.build = function(options) {
  if (!fs.existsSync(options.dir)) { fs.mkdirSync(options.dir); }
  async.series([
    buildHtml('main.js', path.join(options.dir, 'index.html')),
    buildElm(options.elm, path.join(options.dir, 'main.js')),
    buildCSS(options.css, path.join(options.dir, 'main.css'))
  ], function(err, results){
    if(err){
      console.log('Build failed!')
      console.error(err)
    } else {
      console.log('Build succeeded!')
    }
  })
}

exports.renderCSS = renderCSS
exports.renderHtml = renderHtml
exports.renderElm = renderElm
