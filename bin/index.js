#! /usr/bin/env node

var package_json = require('../package.json')
var program = require('commander')
var elmUi = require('./elm-ui')

var options = function() {
  return {
    env: program.env
  }
}

program
  .version(package_json.version)
  .option('-e, --env [env]', 'environment', 'development')

program
  .command('install')
  .description('Installs Elm dependencies')
  .action(function(env, opts) {
    elmUi.install()
  })

program
  .command('docs')
  .description('Generates Elm documentation')
  .action(function(env, opts) {
    elmUi.docs()
  })

program
  .command('help')
  .description('Output usage information')
  .action(function(env, opts) {
    program.outputHelp()
  })

program
  .command('new <dir>')
  .alias('init')
  .description('Scaffolds a new Elm-UI project')
  .action(function(dir) {
    elmUi.scaffold(dir)
  })

program
  .command('server')
  .option('-p, --prefix [prefix]', 'path prefix')
  .alias('start')
  .description('Starts development server')
  .action(function(env, opts) {
    elmUi.serve({
      env: program.env,
      prefix: env.prefix
    })
  })

program
  .command('build')
  .option('-m, --main [file]', 'main file to compile')
  .description('Builds final files')
  .action(function(env, opts) {
    elmUi.build({
      env: program.env,
      main: env.main
    })
  })

program.parse(process.argv)
