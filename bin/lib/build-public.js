var ncp = require('ncp').ncp
var path = require('path')

module.exports = function() {
  return function(callback) {
    console.log('Copying public folder contents...')

    ncp(path.resolve('public'), path.resolve('dist'))

    callback(null, true)
  }
}
