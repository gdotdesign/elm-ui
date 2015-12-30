define([
  'intern!bdd',
  'intern/chai!assert',
  'specs/helpers'
], function(bdd, assert, helpers) {
  bdd.describe('Ui.App', function() {
    var app;

    bdd.before(function() {
      app = helpers
        .getElement(this.remote, 'ui-app')
    })

    bdd.it('should have mobile friendly viewport', function() {
      return app
        .findByCssSelector('meta[name=viewport]')
        .getAttribute('content')
        .then(function(value) {
          assert.equal(value, 'initial-scale=1.0, user-scalable=no')
        })
    })

    bdd.it('should have title', function() {
      return app
        .findByCssSelector('title')
        .getProperty('textContent')
        .then(function(value) {
          assert.equal(value, 'Elm-UI Kitchen Sink')
        })
    })

    bdd.it('should be visible', function() {
      return app
        .isDisplayed()
        .then(assert.ok)
    })

    bdd.it('should load main css', function() {
      return app
        .findByCssSelector('link[href="main.css"]')
    })

    bdd.it('should set page title', function(){
      return app
        .getPageTitle()
        .then(function(value) {
          assert.equal(value, 'Elm-UI Kitchen Sink')
        })
    })
  })
})
