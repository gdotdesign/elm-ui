var renderElm = require('../render/elm')
var uglifyJS = require('uglify-js')
var path = require('path')
var fs = require('fs')

module.exports = function(config, shouldFail) {
  var destination = path.resolve('dist/main.js')
  var source = path.resolve('source/Main.elm')

  return function(callback) {
    console.log('Building JavaScript...')

    renderElm(source, config, shouldFail)(function(err, contents) {
      if (err) {
        return callback(err, null)
      }

      minified = uglifyJS.minify(contents, {
        fromString: true
      })

      fs.writeFileSync(destination, minified.code)

      callback(null, null)
    })
  }
}
