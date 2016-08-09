var generatePackage = require('./generate-package')
var githubInstall = require('./github-install')
var child_process = require('child_process')
var spawn = child_process.spawn
var _ = require('underscore')
var path = require('path')
var fs = require('fs')


var elmPackageExecutable =
  path.resolve(__dirname, '../../../node_modules/elm/binwrappers/elm-package')

module.exports = function() {
  generatePackage()

  // Install dependencies
  console.log('Installing Elm packages...')

  spawn(elmPackageExecutable, ['install', '--yes'], {
    stdio: 'inherit'
  }).on('close', function(code) {
  	githubInstall(function(){
    	process.exit(code)
  	})
  })
}
