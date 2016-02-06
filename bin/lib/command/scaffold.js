var ncp = require('ncp').ncp
var path = require('path')
var fs = require('fs')

var defaultEmlPackage = require('./default-package')

module.exports = function(directory) {
  console.log(`Scaffolding new project into: ${directory}`)

  var elmUiConfig = path.resolve(directory + '/elm-ui.json')
  var destination = path.resolve(directory)

  if (!fs.existsSync(destination)) {
    fs.mkdirSync(destination)
  }

  ncp(path.resolve(__dirname, '../../assets/scaffold'), destination)

  if (fs.existsSync(elmUiConfig)) {
    return
  }

  fs.writeFileSync(elmUiConfig, JSON.stringify(defaultEmlPackage(), null, "  "))
}
