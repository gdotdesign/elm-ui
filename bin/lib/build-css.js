var renderCSS = require('./render-css')
var cleanCSS = require('clean-css')
var path = require('path')
var fs = require('fs')

module.exports = function(shouldFail) {
  var source = path.resolve('stylesheets/main.scss')
  var destination = path.resolve('dist/main.css')

  return function(callback) {
    console.log('Building CSS...')

    renderCSS(source, shouldFail)(function(err, contents) {
      if (err) {
        return callback(err, null)
      }

      minified = new cleanCSS().minify(contents)

      fs.writeFileSync(destination, minified.styles)

      callback(null, null)
    })
  }
}
