#! /usr/bin/env node

var elmUi = require('./elm-ui')
var path = require('path')
var cwd = process.cwd();

var elmSource = path.join(cwd,'source','Main.elm')
var cssSource = path.join(cwd,'stylesheets', 'main.scss')
var publicDir = path.join(cwd,'public')

var program = require('commander');

var options = {
  dir: 'dist',
  elm: elmSource,
  css: cssSource,
  public: publicDir
}

program
  .version('0.0.1')

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
