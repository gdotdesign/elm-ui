var renderError = require('./error').renderCSSError
var autoprefixer = require('autoprefixer')
var sass = require('node-sass')
var path = require('path')
var fs = require('fs')

module.exports = function(file, shouldFail) {
  var deps = require(path.resolve('elm-stuff/exact-dependencies.json'))
  var uiPath =
    path.resolve('elm-stuff/packages/gdotdesign/elm-ui/' +
                 deps['gdotdesign/elm-ui'] +
                 '/stylesheets/ui')

  return function(callback) {
    sass.render({
      includePaths: [uiPath],
      file: file,
    }, function(err, result) {
      if (err) {
        var prettyError =
          renderError('You have errors in of your Sass file(s):', err.formatted)

        if (shouldFail) {
          callback(err.formatted, null)
        } else {
          callback(null, prettyError)
        }
      } else {
        autoprefixer
          .process(result.css)
          .then(function(result2) {
            callback(null, result2.css)
          })
      }
    })
  }
}
