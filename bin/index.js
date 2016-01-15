#! /usr/bin/env node

var exec = require('child_process').execSync;
var elmUi = require('./elm-ui')
var path = require('path')
var cwd = process.cwd()
var fs = require('fs')

var elmSource = path.join(cwd,'source','Main.elm')
var cssSource = path.join(cwd,'stylesheets', 'main.scss')
var publicDir = path.join(cwd,'public')

var program = require('commander');

var options = {
  cwd: cwd,
  dir: 'dist',
  elm: elmSource,
  css: cssSource,
  public: publicDir
}

program
  .version('0.0.1')

program
  .command('init')
  .description('Scaffolds a new Elm-UI project.')
  .action(function(env, opts){
    elmUi.scaffold(options)
  })

program
  .command('server')
  .description('Starts development server.')
  .action(function(env, opts){
    elmUi.serve(options)
  })

program
  .command('build')
  .description('Builds final files.')
  .action(function(env, opts){
    elmUi.build(options)
  })

program.parse(process.argv);
