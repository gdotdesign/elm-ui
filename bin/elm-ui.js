var child_process = require('child_process');
var autoprefixer = require('autoprefixer');
var uglifyJS = require("uglify-js");
var cleanCSS = require('clean-css');
var sass = require('node-sass');
var _ = require('underscore');
var async = require('async');
var path = require('path');
var fs = require('fs');
var ncp = require('ncp').ncp;
var ansi_up = require('ansi_up');
var pty;

try {
  pty = require('pty.js');
} catch (e) {}

var execSync = child_process.execSync;
var spawn = child_process.spawn;

var defaultEmlPackage = function() {
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

RE = function(file, callback) {
  var result = '';

  if (pty) {
    var term = pty.spawn(elmExecutable, `${file} --output test.js --yes`.split(' '), {
      name: 'xterm-color',
      cols: 1000,
      rows: 1000,
    });

    term.on('data', function(data) {
      result += data;
    });

    term.on('close', function() {
      if (result.match('Successfully generated test.js')) {
        callback(null, '')
      } else {
        callback(result.replace(/[\n\r]{1,2}/g, "\n"), '')
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
      if (result.match('Successfully generated test.js')) {
        callback(null, '')
      } else {
        callback(result.replace(/\n/g, "\n"), '')
      }
    });
  }
}

var errorTemplate =
  fs.readFileSync(path.resolve(__dirname, 'assets/error.html'), 'utf-8')
  .replace(/\n/g, '')

renderError = function(title, content) {
  return errorTemplate
    .replace('TITLE', title)
    .replace('ERROR', content)
}

renderElm = function(file) {
  return function(callback) {
    RE(file, function(error, result) {
      if (error) {
        err = ansi_up.ansi_to_html(error)
          .replace(/"/g, '\\"')
          .split("\n")
          .filter(function(line) {
            return !line.match(/^\[/)
          })
          .join("\n")
          .trim()
          .replace(/\n/g, "\\n")
        callback(null, `document.write("${renderError('You have errors in of your Elm file(s):',err)}")`);
      } else {
        callback(null, fs.readFileSync('test.js', 'utf-8'))
        fs.unlink('test.js')
      }
    });
  }
}

readConfig = function(options){
  var file = path.resolve(`config/${options.env}.json`)
  var data;

  try {
    data = JSON.parse(fs.readFileSync(file, 'utf-8'))
  } catch (e) {
    console.log("Error reading environment configuration:\n  > " + e)
    data = {}
  }

  return data;
}

renderHtml = function(config) {
  return `<html>
    <head>
    </head>
    <body style="overflow: hidden;margin:0;">
      <script>
        window.ENV = ${JSON.stringify(config)}
      </script>
      <script src='main.js' type='application/javascript'>
      </script>
      <script>Elm.fullscreen(Elm.Main);</script>
    </body>
  </html>`
}


buildElm = function() {
  var destination = path.resolve('dist/main.js')
  var source = path.resolve('source/Main.elm')

  return function(callback) {
    console.log('Building JavaScript...')

    renderElm(source)(function(err, contents) {
      if (err) {
        return callback(err, null)
      }

      minified = uglifyJS.minify(contents, {
        fromString: true
      });

      fs.writeFileSync(destination, minified.code)

      callback(null, null)
    })
  }
}

buildHtml = function(config) {
  var destination = path.resolve('dist/index.html')

  return function(callback) {
    console.log('Building HTML...')

    fs.writeFileSync(destination, renderHtml(config))

    callback(null, null);
  }
}

buildCSS = function() {
  var source = path.resolve('stylesheets/main.scss')
  var destination = path.resolve('dist/main.css')

  return function(callback) {
    console.log('Building CSS...')

    renderCSS(source)(function(err, contents) {
      if (err) {
        return callback(err, null)
      }

      minified = new cleanCSS().minify(contents)

      fs.writeFileSync(destination, minified.styles)

      callback(null, null);
    })
  }
}

copyPublic = function() {
  return function(callback) {
    console.log('Copying public folder contents...')

    ncp(path.resolve('public'), path.resolve('dist'))

    callback(null, true)
  }
}

exports.scaffold = function(directory) {
  console.log('Scaffolding new project...')

  var elmUiConfig = path.resolve(directory + '/elm-ui.json')
  var destination = path.resolve(directory)

  if (!fs.existsSync(destination)) {
    fs.mkdirSync(destination);
  }

  ncp(path.resolve(__dirname, 'assets/scaffold'), destination)

  if (fs.existsSync(elmUiConfig)) {
    return;
  }

  fs.writeFileSync(elmUiConfig, JSON.stringify(defaultEmlPackage(), null, "  "))
}

exports.serve = function(options) {
  var bs = require("browser-sync").create();
  var router = require('koa-router')();
  var serve = require('koa-static');
  var config = readConfig(options);
  var app = require('koa')();

  bs.watch("source/**/*.elm").on("change", bs.reload);
  bs.watch("stylesheets/**/*.scss", function (event, file) {
    if (event === "change") { bs.reload("*.css"); }
  });

  bs.init({
    proxy: "localhost:8001",
    port: 8002,
    ui: { port: 8003 },
    logFileChanges: false,
    reloadOnRestart: true,
    notify: false,
    open: false
  });

  router.get('/', function*(next) {
    this.body = renderHtml(config)
  })

  router.get('/main.js', function*(next) {
    this.type = 'text/javascript';
    this.body = yield renderElm(path.resolve('source/Main.elm'))
  })

  router.get('/main.css', function*(next) {
    this.type = 'text/css';
    this.body = yield renderCSS(path.resolve('stylesheets/main.scss'))
  })

  app
    .use(router.routes())
    .use(serve(path.resolve('public')));

  app.listen(8001);

  console.log("Listening on localhost:8001")
}

exports.install = function() {
  var ownElmPackage = path.resolve(__dirname, '../elm-package.json')
  var elmPackage = path.resolve('elm-package.json')
  var elmUiConfig = path.resolve('elm-ui.json')
  var ownPackage = JSON.parse(fs.readFileSync(ownElmPackage, 'utf-8'))

  // Tr to read configuration
  try {
    cwdPackage = JSON.parse(fs.readFileSync(elmUiConfig, 'utf-8'))
  } catch (e) {
    console.log('Error reading elm-ui.json, using defaults.\n  > ' + e)
    cwdPackage = defaultEmlPackage()
  }

  // Add dependencies
  cwdPackage["source-directories"].push(path.resolve(__dirname, "../source"))
  _.extend(cwdPackage.dependencies, ownPackage.dependencies)

  // Write elm-package.json
  fs.writeFileSync(elmPackage, JSON.stringify(cwdPackage, null, "  "))

  // Install dependencies
  console.log('Installing elm packages...')
  spawn(elmPackageExecutable, ['install', '--yes'], {
      stdio: 'inherit'
    })
    .on('close', function(code) {
      process.exit(code)
    })
}

exports.build = function(options) {
  var destination = path.resolve('dist')
  var config = readConfig(options);

  // Ensure destination
  if (!fs.existsSync(destination)) {
    fs.mkdirSync(destination);
  }

  // Build things with async
  async.series([
    copyPublic(),
    buildHtml(config),
    buildElm(),
    buildCSS()
  ], function(err, results) {
    if (err) {
      console.error(err)
      console.log('Build failed!')
      process.exit(1)
    } else {
      console.log('Build succeeded!')
    }
  })
}
