#! /usr/bin/env node

var exec = require('child_process').execSync;
var elmUi = require('./elm-ui')
var _ = require('underscore')
var path = require('path')
var cwd = process.cwd()
var fs = require('fs')

var elmSource = path.join(cwd,'source','Main.elm')
var cssSource = path.join(cwd,'stylesheets', 'main.scss')
var publicDir = path.join(cwd,'public')

var ownElmPackage = path.resolve(__dirname, '../elm-package.json')
var elmPackage = path.join(cwd, 'elm-package.json')

var elmPackageExecutable =
  path.resolve(__dirname, '../node_modules/elm/binwrappers/elm-package');

var defaultEmlPackage = {
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

var program = require('commander');

var options = {
  dir: 'dist',
  elm: elmSource,
  css: cssSource,
  public: publicDir
}

var fixElmPackage = function(){
  if(!fs.existsSync(elmPackage)) {
    fs.writeFileSync(elmPackage, JSON.stringify(defaultEmlPackage,  null, "  ")) }

  cwdPackage = JSON.parse(fs.readFileSync(elmPackage, 'utf-8'))
  ownPackage = JSON.parse(fs.readFileSync(ownElmPackage, 'utf-8'))

  cwdPackage["source-directories"] = ["source", path.resolve(__dirname, "../source")]
  cwdPackage.dependencies = ownPackage.dependencies

  fs.writeFileSync(elmPackage, JSON.stringify(cwdPackage, null, "  "))
  exec(`${elmPackageExecutable} install --yes`)
}

program
  .version('0.0.1')

program
  .command('server')
  .description('Starts development server.')
  .action(function(env, opts){
    fixElmPackage()
    elmUi.serve(options)
  })

program
  .command('build')
  .description('Builds final files.')
  .action(function(env, opts){
    fixElmPackage()
    elmUi.build(options)
  })

program.parse(process.argv);
