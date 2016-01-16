#! /usr/bin/env node

var exec = require('child_process').execSync
var program = require('commander')
var elmUi = require('./elm-ui')
var path = require('path')
var fs = require('fs')

program
  .version('0.0.1')

program
  .command('install')
  .description('Installs Elm dependencies')
  .action(function(env,opts){
    elmUi.install()
  })

program
  .command('new <dir>')
  .description('Scaffolds a new Elm-UI project')
  .action(function(dir){
    elmUi.scaffold(dir)
  })

program
  .command('server')
  .description('Starts development server')
  .action(function(env, opts){
    elmUi.serve()
  })

program
  .command('build')
  .description('Builds final files')
  .action(function(env, opts){
    elmUi.build()
  })

program.parse(process.argv);
