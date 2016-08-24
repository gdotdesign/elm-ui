var ncp = require('ncp').ncp
var path = require('path')
var fs = require('fs')

module.exports = function(directory) {
  console.log(`Scaffolding new project into: ${directory}`)

  var destination = path.resolve(directory)

  if (!fs.existsSync(destination)) {
    fs.mkdirSync(destination)
  }

  ncp(path.resolve(__dirname, '../../assets/scaffold'), destination)
}
