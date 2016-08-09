var request = require('request')
var path = require('path')
var fs = require('fs')
var async = require('async')
var unzip = require('unzipper')
var semver = require('semver')

writeExactDependencies = function(package, version){
  var filePath = path.resolve('elm-stuff/exact-dependencies.json')
  var dependencies = require(filePath)
  dependencies[package] = version
  fs.writeFileSync(filePath, JSON.stringify(dependencies, null, "  "))

  var elmPackagePath = path.resolve('elm-package.json')
  var elmPackage = require(elmPackagePath)
  elmPackage.dependencies[package] = version + " <= v < " + semver.inc(version, 'patch')
  fs.writeFileSync(elmPackagePath, JSON.stringify(elmPackage, null, "  "))
}

installExternalPackage = function(package, ref) {
  return function(callback){
    var packageUrl = 'https://github.com/' + package + '/raw/' + ref + '/elm-package.json'
    var archiveUrl = 'https://github.com/' + package + '/archive/' + ref + '.zip'

    request.get(packageUrl, function(error, response, body){

      var config = JSON.parse(body)
      var packagePath = path.resolve('elm-stuff/packages/' + package)

      console.log(packagePath)

      request
        .get(archiveUrl)
        .pipe(unzip.Extract({ path: packagePath }))
        .on('close', function(){
          writeExactDependencies(package, config.version)
          var files = fs.readdirSync(packagePath)
          fs.rename(path.resolve(packagePath, files[0]),
                    path.resolve(packagePath, config.version))
          console.log('Installed from github: ' + package)
          callback()
        })
    })
  }
}

module.exports = function(callback) {
  var elmUiConfig = require(path.resolve('elm-ui.json'))
  var deps = elmUiConfig['github-dependencies']

  var calls = Object.keys(elmUiConfig['github-dependencies'])
                    .map(function(package){
                      return installExternalPackage(package, deps[package])
                    })
  async.series(calls, function(){
    callback()
  })
}
