#! /usr/bin/env node

var exec = require('child_process').execSync
var program = require('commander')
var elmUi = require('./elm-ui')
var path = require('path')
var fs = require('fs')

var options = function(){
  return { env: program.env }
}

program
  .version('0.1.2')
  .option('-e, --env [env]', 'Environment', 'development')

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
    // Create a Browsersync instance
    var bs = require("browser-sync").create();

    // Listen to change events on HTML and reload
    bs.watch("source/**/*.elm").on("change", bs.reload);
    bs.watch("stylesheets/**/*.scss", function (event, file) {
      if (event === "change") {
        bs.reload("*.css");
      }
    });

    // Now init the Browsersync server
    bs.init({
      proxy: "localhost:8001",
    });
    elmUi.serve(options())
  })

program
  .command('build')
  .description('Builds final files')
  .action(function(env, opts){
    elmUi.build(options())
  })

program.parse(process.argv)
