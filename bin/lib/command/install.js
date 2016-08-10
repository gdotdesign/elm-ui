var SemverResolver = require('semver-resolver').SemverResolver
var exec = require('child_process').exec
var extract = require('extract-zip')
var request = require('request')
var semver = require('semver')
var colors = require('colors')
var async = require('async')
var path = require('path')
var tmp = require('tmp')
var fs = require('fs')

// Installs a package directly from github...
installExternalPackage = function(package, ref) {
  return function(callback){
    if(fs.existsSync(path.resolve('elm-stuff/packages/' + package + '/' + ref))){
      return callback()
    }

    var packageUrl = 'https://github.com/' + package + '/raw/' + ref + '/elm-package.json'
    var archiveUrl = 'https://github.com/' + package + '/archive/' + ref + '.zip'

    request.get(packageUrl, function(error, response, body){

      var config = JSON.parse(body)
      var packagePath = path.resolve('elm-stuff/packages/' + package)

      var tmpobj = tmp.fileSync()

      request
        .get(archiveUrl)
        .pipe(fs.createWriteStream(tmpobj.name))
        .on('finish', function(){
          extract(tmpobj.name, { dir: packagePath }, function(error){
            if(error) {
              console.log(' ✘'.red, package + ' - ' + ref)
              console.log('   ▶', error)
              callback(true)
            } else {
              var repo = package.split('/').pop()
              fs.renameSync(path.resolve(packagePath, repo + '-' + ref),
                            path.resolve(packagePath, ref))
              console.log(' ●'.green, package + ' - ' + ref)
              callback()
            }
            tmpobj.removeCallback()
          })
        })
    })
  }
}

var getSemerVersion = function(version) {
  var match = version.match(/(\d+\.\d+\.\d+)<=v<(\d+\.\d+\.\d+)/)
  if(match) { return '>=' + match[1] + ' <' + match[2] }
  var match = version.match(/(\d+\.\d+\.\d+)<=v<=(\d+\.\d+\.\d+)/)
  if(match) { return '>=' + match[1] + ' <=' + match[2] }
  var match = version.match(/(\d+\.\d+\.\d+)<v<=(\d+\.\d+\.\d+)/)
  if(match) { '>' + match[1] + ' <=' + match[2] }
  var match = version.match(/(\d+\.\d+\.\d+)<v<(\d+\.\d+\.\d+)/)
  if(match) { '>' + match[1] + ' <' + match[2] }
  return version
}

var transformDependencies = function(deps){
  var result = {}
  Object.keys(deps).forEach(function(key) {
    result[key] = getSemerVersion(deps[key].replace(/\s/g, ''))
  })
  return result
}

var getDependencies = function(package, ref) {
  return new Promise(function (fulfill, reject){
    getPackageJson(package, ref)
      .then(function(json){
        fulfill(transformDependencies(json.dependencies))
      })
  })
}

var getPackageJson = function(package, ref){
  var packageUrl = 'https://github.com/' + package + '/raw/' + ref + '/elm-package.json'

  return new Promise(function (fulfill, reject){
    request.get(packageUrl, function(error, response, body){
      fulfill(JSON.parse(body))
    })
  })
}

var getVersions = function(package){
  return new Promise(function (fulfill, reject){
    var cmd = 'git ls-remote git://github.com/' +  package + ".git | awk -F/ '{ print $3 }'"
    exec(cmd, function(error, stdout, stderr){
      var versions = stdout.trim()
                           .split("\n")
                           .filter(function(version) {
                              return semver.valid(version)
                           })
      fulfill(versions)
    })
  })
}

var getConstraits = function(package, version){
  return getDependencies(package, version)
}

module.exports = function(){
  var packageConfig = require(path.resolve('elm-package.json'))
  var packages = transformDependencies(packageConfig.dependencies)
  var resolver =  new SemverResolver(packages, getVersions, getConstraits)

  console.log('Resolving versions...')

  resolver.resolve().then(function(deps){
    var installs = Object.keys(deps).map(function(package){
      return installExternalPackage(package, deps[package])
    })
  	console.log('Starting downloads...\n')
    async.parallel(installs, function(error){
      if(error) {
        console.log('\nSome packages failed to install!')
      } else {
        fs.writeFileSync(path.resolve('elm-stuff/exact-dependencies.json'), JSON.stringify(deps, null, '  '))
        console.log('\nPackages configured successfully!')
      }
    })
  }, function(){
    console.log('error', arguments)
  })
}
