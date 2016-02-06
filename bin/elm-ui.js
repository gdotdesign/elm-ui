var child_process = require('child_process');

var spawn = child_process.spawn;
var _ = require('underscore');
var path = require('path')
var fs = require('fs')

var defaultEmlPackage = function() {
  return {
    "version": "1.0.0",
    "summary": "Elm-UI Project",
    "repository": "https://github.com/user/project.git",
    "license": "BSD3",
    "native-modules": true,
    "source-directories": [
      "source"
    ],
    "exposed-modules": [],
    "dependencies": {
      "elm-lang/core": "3.0.0 <= v < 4.0.0"
    },
    "elm-version": "0.16.0 <= v < 0.17.0"
  }
}

var elmPackageExecutable =
  path.resolve(__dirname, '../node_modules/elm/binwrappers/elm-package');

exports.scaffold = function(directory) {
  console.log('Scaffolding new project...')

  var elmUiConfig = path.resolve(directory + '/elm-ui.json')
  var destination = path.resolve(directory)

  if (!fs.existsSync(destination)) {
    fs.mkdirSync(destination);
  }

  ncp(path.resolve(__dirname, 'assets/scaffold'), destination)

  if (fs.existsSync(elmUiConfig)) {
    return;
  }

  fs.writeFileSync(elmUiConfig, JSON.stringify(defaultEmlPackage(), null, "  "))
}

exports.install = function() {
  var ownElmPackage = path.resolve(__dirname, '../elm-package.json')
  var elmPackage = path.resolve('elm-package.json')
  var elmUiConfig = path.resolve('elm-ui.json')
  var ownPackage = JSON.parse(fs.readFileSync(ownElmPackage, 'utf-8'))

  // Tr to read configuration
  try {
    cwdPackage = JSON.parse(fs.readFileSync(elmUiConfig, 'utf-8'))
  } catch (e) {
    console.log('Error reading elm-ui.json, using defaults.\n  > ' + e)
    cwdPackage = defaultEmlPackage()
  }

  // Add dependencies
  cwdPackage["source-directories"].push(path.resolve(__dirname, "../source"))
  _.extend(cwdPackage.dependencies, ownPackage.dependencies)

  // Write elm-package.json
  fs.writeFileSync(elmPackage, JSON.stringify(cwdPackage, null, "  "))

  // Install dependencies
  console.log('Installing elm packages...')
  spawn(elmPackageExecutable, ['install', '--yes'], {
      stdio: 'inherit'
    })
    .on('close', function(code) {
      process.exit(code)
    })
}

exports.build = require('./lib/command-build')
exports.serve = require('./lib/command-serve')
