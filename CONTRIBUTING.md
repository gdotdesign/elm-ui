# Contributing
Any contributions are welcome.

## Installing dependencies
After cloning the repository you will need to install both **Elm** and **Node** dependencies:
  * To install the Node ones run `npm install` in the root of the directory
  * To install the Elm ones run `npm run elm-install` in the root of the directory

## Development environment
You can start the development environment with the `npm start` command.

## The Main Module
The main module contains the **examples (kitchen sink)** of all components (which are used for tests).

## Styles
The stylesheet directory contains the styles for the components.

## Tests
Tests are run using [Nightwatch.js](http://nightwatchjs.org):

- Install selenium for your system into spec/vendor/selenium-server.jar
- The following command will run all the tests in Chrome and Firefox `npm test`
