define([
  'intern!bdd',
  'intern/chai!assert',
  'specs/helpers'
], function(bdd, assert, helpers) {
  bdd.describe('Ui.Button', function() {

    bdd.describe('Enabled', function() {
      var button;

      bdd.beforeEach(function() {
        button = helpers
          .getElement(this.remote, 'td ui-button.size-big.ui-button-primary')
      })

      bdd.it('should have tabindex', function() {
        return button
          .getAttribute('tabindex')
          .then(helpers.assertTabindex)
      });

      bdd.it('should trigger action on click', function() {
        return helpers.assertAlert(button.click())
      })

      bdd.it('should trigger action on enter', function() {
        return helpers.assertAlert(button.type(""))
      })

      bdd.it('should trigger action on space', function() {
        return helpers.assertAlert(button.type(""))
      })
    })

    bdd.describe('Disabled', function() {
      var button;

      bdd.before(function() {
        button = helpers.getElement(this.remote, 'td ui-button.disabled')
      })

      bdd.it('should not have tabindex', function() {
        return button
          .getAttribute('tabindex')
          .then(assert.isNull)
      })

      bdd.it('should not have event handlers', function() {
        return button
          .getProperty('onclick').then(assert.isNull)
          .getProperty('onkeydown').then(assert.isNull)
      })

      bdd.it('should have disabled state', function() {
        return button
          .getComputedStyle('cursor').then(helpers.assertNotAllowed)
          .getComputedStyle('opacity').then(helpers.assertDisabledOpacity)
      })
    })

    bdd.describe('Styles', function() {
      bdd.describe('Big', function() {
        var button;

        bdd.before(function() {
          button = helpers.getElement(this.remote, 'td ui-button.size-big')
        })

        bdd.it('should be the right styles', function() {
          return button
            .getSize().then(function(value) {
              assert.equal(value.height, 49)
            })
            .getComputedStyle('padding-left').then(function(value) {
              assert.equal(value, '27.5px')
            })
            .getComputedStyle('padding-right').then(function(value) {
              assert.equal(value, '27.5px')
            })
            .getComputedStyle('font-size').then(function(value) {
              assert.equal(value, '22px')
            })
        })
      })

      bdd.describe('Medium', function() {
        var button;

        bdd.before(function() {
          button = helpers.getElement(this.remote, 'td ui-button.size-medium')
        })

        bdd.it('should be the right styles', function() {
          return button
            .getSize().then(function(value) {
              assert.equal(value.height, 36)
            })
            .getComputedStyle('padding-left').then(function(value) {
              assert.equal(value, '20px')
            })
            .getComputedStyle('padding-right').then(function(value) {
              assert.equal(value, '20px')
            })
            .getComputedStyle('font-size').then(function(value) {
              assert.equal(value, '16px')
            })
        })
      })

      bdd.describe('Small', function() {
        var button;

        bdd.before(function() {
          button = helpers.getElement(this.remote, 'td ui-button.size-small')
        })

        bdd.it('should be the right styles', function() {
          return button
            .getSize().then(function(value) {
              assert.equal(value.height, 27)
            })
            .getComputedStyle('padding-left').then(function(value) {
              assert.equal(value, '15px')
            })
            .getComputedStyle('padding-right').then(function(value) {
              assert.equal(value, '15px')
            })
            .getComputedStyle('font-size').then(function(value) {
              assert.equal(value, '12px')
            })
        })
      })
    })
  });
});
