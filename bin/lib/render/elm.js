var renderError = require('./error').renderHTMLError
var which = require('npm-which')(__dirname)
var spawn = require('child_process').spawn
var path = require('path')
var fs = require('fs')

// Find the elm-make executable
var elmExecutable = which.sync('elm-make')

// Try to load pty.js beacause it's an optional dependency.
var pty
try {
  pty = require('pty.js')
} catch (e) {}

// Renders an .elm file.
var render = function(file, debug, callback) {
  var filename = `test-${+Date.now()}.js`
  var arguments = `${file} --output ${filename} --yes`.split(' ')
  var result = ''
  var command
  var regexp

  if (debug) {
    arguments.push('--debug')
  }

  // If there is pty.js we can have colored output
  if (pty) {
    regexp = /[\n\r]{1,2}/g

    command = pty.spawn(elmExecutable, arguments, {
      name: 'xterm-color',
      cols: 1000,
      rows: 1000,
    })

    command.on('data', function(data) {
      result += data
    })
  } else {
    regexp = /\n/g

    command = spawn(elmExecutable, arguments)

    command.stdout.on('data', (data) => {
      result += data
    })

    command.stderr.on('data', (data) => {
      result += data
    })
  }

  command.on('close', function() {
    if (result.match('Successfully generated test')) {
      callback(null, '', filename)
    } else {
      callback(result.replace(regexp, "\n"), '', filename)
    }
  })
}

module.exports = function(file, debug, config, shouldFail) {
  return function(callback) {
    render(file, debug, function(error, result, filename) {
      if (error) {
        var prettyError =
          renderError('You have errors in of your Elm file(s):', error)

        if (shouldFail) {
          callback(error, null)
        } else {
          callback(null, prettyError)
        }
      } else {
        var contents = [
          `window.ENV = ${JSON.stringify(config)};`,
          fs.readFileSync(filename, 'utf-8')
            // NOTICE: This is a fix for in elm-lang/core scheduler
            .replace('setTimeout(work, 0);', 'requestAnimationFrame(work);'),
        ].join('\n')
        callback(null, contents)
        fs.unlink(filename)
      }
    })
  }
}
