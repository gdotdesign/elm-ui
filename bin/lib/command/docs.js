var generatePackage = require('./generate-package')
var child_process = require('child_process')
var spawn = child_process.spawn
var path = require('path')

// Find the elm-make executable
var elmExecutable =
  path.resolve(__dirname, '../../../node_modules/elm/binwrappers/elm-make')

module.exports = function() {
  generatePackage()

  // Generate documentation
  console.log('Generating Elm documentation...')

  spawn(elmExecutable, ['--docs=documentation.json'], {
    stdio: 'inherit'
  }).on('close', function(code) {
    process.exit(code)
  })
}
