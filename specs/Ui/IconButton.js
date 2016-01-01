define([
  'intern!bdd',
  'intern/chai!assert',
  'specs/helpers'
], function(bdd, assert, helpers) {
  bdd.describe('Ui.IconButton', function() {
    bdd.describe('Left Side', function(){
      var button;

      bdd.before(function() {
        button = helpers
          .getElement(this.remote, 'ui-icon-button.ui-button-secondary')
      })

      bdd.it('span should have left margin', function() {
        return button
          .findByCssSelector('span')
          .getComputedStyle('margin-left')
          .then(function(value){ assert.equal(value, '10px') })
      });
    })

    bdd.describe('No Text', function(){
      var button;

      bdd.before(function() {
        button = helpers
          .getElement(this.remote, 'ui-icon-button.ui-button-primary.ui-button-medium')
      })

      bdd.it('children should not have any margin', function() {
        return button
          .getComputedStyle('width')
          .then(function(value){ assert.equal(value, '54px') })
      });
    })

    bdd.describe('Right Side', function(){
      var button;

      bdd.before(function() {
        button = helpers
          .getElement(this.remote, 'ui-icon-button.ui-button-success')
      })

      bdd.it('span should have left margin', function() {
        return button
          .findByCssSelector('ui-icon')
          .getComputedStyle('margin-left')
          .then(function(value){ assert.equal(value, '10px') })
      });
    })
  })
});
