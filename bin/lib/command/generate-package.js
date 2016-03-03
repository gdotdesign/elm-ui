var _ = require('underscore')
var path = require('path')
var fs = require('fs')

var defaultEmlPackage = require('./default-package')

module.exports = function() {
  var ownPackage = require(path.resolve(__dirname, '../../../elm-package.json'))

  var elmPackage = path.resolve('elm-package.json')
  var elmUiConfig = path.resolve('elm-ui.json')

  // Try to read configuration
  try {
    cwdPackage = require(elmUiConfig)
  } catch (e) {
    console.log('Error reading elm-ui.json, using defaults.\n  > ' + e)
    cwdPackage = defaultEmlPackage()
  }

  // Add dependencies
  cwdPackage["source-directories"]
    .push(path.resolve(__dirname, "../../../source"))

  _.extend(cwdPackage.dependencies, ownPackage.dependencies)

  // Write elm-package.json
  fs.writeFileSync(elmPackage, JSON.stringify(cwdPackage, null, "  "))
}
