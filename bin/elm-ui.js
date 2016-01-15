var child_process = require('child_process');
var autoprefixer = require('autoprefixer');
var uglifyJS = require("uglify-js");
var cleanCSS = require('clean-css');
var sass = require('node-sass');
var _ = require('underscore');
var async = require('async');
var path = require('path');
var fs = require('fs');
var ansi_up = require('ansi_up');
var pty;
try {
  pty = require('pty.js');
} catch (e) {
}

var execSync = child_process.execSync;
var spawn = child_process.spawn;

var defaultEmlPackage = function(){
  return {
    "version": "1.0.0",
    "summary": "Elm-UI Project",
    "repository": "https://github.com/user/project.git",
    "license": "BSD3",
    "native-modules": true,
    "source-directories": [
      "source"
    ],
    "exposed-modules": [],
    "dependencies": {
      "elm-lang/core": "3.0.0 <= v < 4.0.0"
    },
    "elm-version": "0.16.0 <= v < 0.17.0"
  }
}

var elmExecutable =
  path.resolve(__dirname, '../node_modules/elm/binwrappers/elm-make');

var elmPackageExecutable =
  path.resolve(__dirname, '../node_modules/elm/binwrappers/elm-package');

fixElmPackage = function(options) {
  var cwd = options.cwd
  var ownElmPackage = path.resolve(__dirname, '../elm-package.json')
  var elmPackage = path.join(cwd, 'elm-package.json')
  var elmUiConfig = path.join(cwd, 'elm-ui.json')
  var ownPackage = JSON.parse(fs.readFileSync(ownElmPackage, 'utf-8'))

  try {
    cwdPackage = JSON.parse(fs.readFileSync(elmUiConfig, 'utf-8'))
  } catch (e) {
    cwdPackage = defaultEmlPackage()
  }

  cwdPackage["source-directories"].push(path.resolve(__dirname, "../source"))
  _.extend(cwdPackage.dependencies, ownPackage.dependencies)

  fs.writeFileSync(elmPackage, JSON.stringify(cwdPackage, null, "  "))
  console.log('Installing elm packages...')
  execSync(`${elmPackageExecutable} install --yes`)
}

renderCSS = function(file) {
  return function(callback) {
    sass.render({
      includePaths: [path.resolve(__dirname, '../stylesheets/ui')],
      file: file,
    }, function(err, result) {
      if (err) {
        var err2 = err.formatted.replace(/\n/g, "\\A")
          .replace(/"/g, '\\"')
        var css = `
        body::before {
          background: white;
          content: "You have errors in of your Sass file(s):";
          position: fixed;
          font-size: 24px;
          color: #333;
          top: 0;
          left: 0;
          right: 0;
          font-weight: bold;
          padding: 40px;
          font-family: sans-serif;
        }
        body::after {
          content: "${err2}";
          white-space: pre;
          display: block;
          position: fixed;
          top: 90px;
          left: 0;
          right: 0;
          font-size: 16px;
          background: white;
          color: #333;
          padding: 40px;
          line-height: 25px;
          font-family: monospace;
          bottom: 0;
          padding-top: 0;
        }
        `
        callback(null, css)
      } else {
        autoprefixer
          .process(result.css)
          .then(function(result2) {
            callback(null, result2.css)
          })
      }
    });
  }
}

RE = function(file, callback){
  var result = '';

  if(pty) {
    var term = pty.spawn(elmExecutable, `${file} --output test.js --yes`.split(' '), {
      name: 'xterm-color',
      cols: 1000,
      rows: 1000,
    });

    term.on('data', function(data) {
      result += data;
    });

    term.on('close', function(){
      if(result.match('Successfully generated test.js')){
        callback(null,'')
      } else {
        callback(result.replace(/[\n\r]{1,2}/g, "\n"),'')
      }
    })
  } else {
    var cmd = spawn(elmExecutable, `${file} --output test.js --yes`.split(' '))

    cmd.stdout.on('data', (data) => {
      result += data;
    });

    cmd.stderr.on('data', (data) => {
      result += data;
    });

    cmd.on('close', (code) => {
      if(result.match('Successfully generated test.js')){
        callback(null,'')
      } else {
        callback(result.replace(/\n/g, "\n"),'')
      }
    });
  }
}

var errorTemplate =
  fs.readFileSync(path.resolve(__dirname, 'assets/error.html'), 'utf-8')
  .replace(/\n/g,'')

renderError = function(title,content){
  return errorTemplate
    .replace('TITLE', title)
    .replace('ERROR', content)
}

renderElm = function(file) {
  return function(callback) {
    RE(file, function(error,result) {
      if (error) {
        err = ansi_up.ansi_to_html(error)
          .replace(/"/g, '\\"')
          .split("\n")
          .filter(function(line) { return !line.match(/^\[/) })
          .join("\n")
          .replace(/\n/g, "\\n")
        callback(null, `document.write("${renderError('You have errors in of your Elm file(s):',err)}")`);
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

buildElm = function(source, dest) {
  return function(callback) {
    console.log('Building JS...')
    renderElm(source)(function(err, contents) {
      if (err) {
        return callback(err, null)
      }
      minified = uglifyJS.minify(contents, {
        fromString: true
      });
      fs.writeFileSync(dest, minified.code)
      callback(null, null);
    })
  }
}

buildHtml = function(str, dest) {
  return function(callback) {
    console.log('Building HTML...')
    var html = renderHtml(str)
    fs.writeFileSync(dest, html)
    callback(null, null);
  }
}

buildCSS = function(source, dest) {
  return function(callback) {
    console.log('Building CSS...')
    renderCSS(source)(function(err, contents) {
      if (err) {
        return callback(err, null)
      }
      minified = new cleanCSS().minify(contents)
      fs.writeFileSync(dest, minified.styles)
      callback(null, null);
    })
  }
}

exports.scaffold = function(options) {

}

exports.serve = function(options) {
  var router = require('koa-router')();
  var serve = require('koa-static');
  var app = require('koa')();

  router.get('/', function*(next) {
    this.body = renderHtml('main.js')
  })

  router.get('/main.js', function*(next) {
    fixElmPackage(options)
    this.type = 'text/javascript';
    this.body = yield renderElm(options.elm)
  })

  router.get('/main.css', function*(next) {
    this.type = 'text/css';
    this.body = yield renderCSS(options.css)
  })

  app
    .use(router.routes())
    .use(serve(options.public));

  app.listen(8001);

  console.log("Listening on localhost:8001")
}

exports.build = function(options) {
  fixElmPackage(options)
  if (!fs.existsSync(options.dir)) {
    fs.mkdirSync(options.dir);
  }
  async.series([
    buildHtml('main.js', path.join(options.dir, 'index.html')),
    buildElm(options.elm, path.join(options.dir, 'main.js')),
    buildCSS(options.css, path.join(options.dir, 'main.css'))
  ], function(err, results) {
    if (err) {
      console.log('Build failed!')
      console.error(err)
    } else {
      console.log('Build succeeded!')
    }
  })
}
