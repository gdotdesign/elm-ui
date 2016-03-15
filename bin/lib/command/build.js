var buildPublic = require('../build/public')
var buildHtml = require('../build/html')
var buildElm = require('../build/elm')
var buildCSS = require('../build/css')

var readConfig = require('./read-config')

var async = require('async')
var path = require('path')
var fs = require('fs')

var formatError = function(error) {
  return error
    .split('\n')
    .map(function(line) {
      return '  > ' + line
    })
    .join('\n')
}

module.exports = function(options) {
  var destination = path.resolve('dist')
  var config = readConfig(options);

  // Ensure destination
  if (!fs.existsSync(destination)) {
    fs.mkdirSync(destination);
  }

  // Build things with async
  async.series([
    buildPublic(),
    buildHtml(),
    buildElm(config,true),
    buildCSS(true)
  ], function(error, results) {
    if (error) {
      console.log(formatError(error))
      console.log('\nBuild failed!')
      process.exit(1)
    } else {
      console.log('Build succeeded!')
    }
  })
}
