define([
  'intern!bdd',
  'intern/chai!assert',
  'specs/helpers',
  'intern/dojo/node!leadfoot/helpers/pollUntil'
], function (bdd, assert, helpers, pollUntil) {
  bdd.describe('Ui.Button', function(){

    bdd.describe('Enabled', function(){
      var button;

      bdd.before(function(){
        button = helpers
          .getElement(this.remote, 'td ui-button.size-big.ui-button-primary')
      })

      bdd.it('should have tabindex', function () {
        return button
          .getAttribute('tabindex')
          .then(helpers.assertTabindex)
      });

      bdd.it('should trigger action on click', function(){
        return helpers.assertAlert(button.click())
      })

      bdd.it('should trigger action on enter', function(){
        return helpers.assertAlert(button.type(""))
      })

      bdd.it('should trigger action on space', function(){
        return helpers.assertAlert(button.type(""))
      })
    })

    bdd.describe('Disabled', function(){
      var button;

      bdd.before(function(){
        button = helpers.getElement(this.remote, 'td ui-button.disabled')
      })

      bdd.it('should not have tabindex', function(){
        return button
          .getAttribute('tabindex')
          .then(assert.isNull)
      })

      bdd.it('should not have event handlers', function(){
        return button
          .getProperty('onclick').then(assert.isNull)
          .getProperty('onkeydown').then(assert.isNull)
      })

      bdd.it('should have disabled state', function(){
        return button
          .getComputedStyle('cursor').then(helpers.assertNotAllowed)
          .getComputedStyle('opacity').then(helpers.assertDisabledOpacity)
      })
    })

    bdd.describe('Styles', function(){
      bdd.describe('Big', function(){
        var button;

        bdd.before(function(){
          button = helpers.getElement(this.remote, 'td ui-button.size-big')
        })

        bdd.it('should be 49px height', function(){
          button.getSize(function(value){
            assert.equal(value.height, 49)
          })
        })
      })
    })
  });
});
