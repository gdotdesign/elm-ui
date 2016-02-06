var renderError = require('./error').renderHTMLError
var child_process = require('child_process')
var spawn = child_process.spawn
var path = require('path')
var fs = require('fs')

// Find the elm-make executable
var elmExecutable =
  path.resolve(__dirname, '../../../node_modules/elm/binwrappers/elm-make')

// Try to load pty.js beacause it's an optional dependency.
var pty
try {
  pty = require('pty.js')
} catch (e) {}

// Renders an .elm file.
var render = function(file, callback) {
  var arguments = `${file} --output test.js --yes`.split(' ')
  var result = ''
  var command
  var regexp

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
    if (result.match('Successfully generated test.js')) {
      callback(null, '')
    } else {
      callback(result.replace(regexp, "\n"), '')
    }
  })
}

module.exports = function(file, shouldFail) {
  return function(callback) {
    render(file, function(error, result) {
      if (error) {
        var prettyError =
          renderError('You have errors in of your Elm file(s):', error)

        if (shouldFail) {
          callback(error, null)
        } else {
          callback(null, prettyError)
        }
      } else {
        callback(null, fs.readFileSync('test.js', 'utf-8'))
        fs.unlink('test.js')
      }
    })
  }
}
