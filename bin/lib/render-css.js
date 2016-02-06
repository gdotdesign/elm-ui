var renderError = require('./render-error').renderCSSError
var autoprefixer = require('autoprefixer')
var sass = require('node-sass')
var path = require('path')

module.exports = function(file, shouldFail) {
  return function(callback) {
    sass.render({
      includePaths: [path.resolve(__dirname, '../stylesheets/ui')],
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
