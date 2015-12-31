define([
  'intern!bdd',
  'intern/chai!assert',
  'specs/helpers'
], function(bdd, assert, helpers) {
  bdd.describe('Ui.Checkbox', function() {
    ['ui-checkbox',
      'ui-checkbox-toggle',
      'ui-checkbox-radio'
    ].forEach(function(type) {
      bdd.describe(type, function() {
        bdd.describe('Enabled', function() {
          var checkbox;

          bdd.beforeEach(function() {
            checkbox = helpers
              .getElement(this.remote, `td ${type}`)
          })

          bdd.it('should have tabindex', function() {
            return checkbox
              .getAttribute('tabindex')
              .then(helpers.assertTabindex)
          });

          bdd.it('should toggle on click', function() {
            return checkbox
              .getAttribute('class').then(helpers.assertUnChecked)
              .click().sleep(250)
              .getAttribute('class').then(helpers.assertChecked)
          })

          bdd.it('should toggle on enter', function() {
            return checkbox
              .getAttribute('class').then(helpers.assertUnChecked)
              .type("").sleep(250)
              .getAttribute('class').then(helpers.assertChecked)
          })

          bdd.it('should toggle on space', function() {
            return checkbox
              .getAttribute('class').then(helpers.assertUnChecked)
              .type("").sleep(250)
              .getAttribute('class').then(helpers.assertChecked)
          })
        })

        bdd.describe('Readonly', function() {
          var checkbox;

          bdd.beforeEach(function() {
            checkbox = helpers
              .getElement(this.remote, `td:nth-child(2) ${type}`)
          });

          bdd.it('should not oggle on click', function() {
            return checkbox
              .getAttribute('class').then(helpers.assertUnChecked)
              .click().sleep(250)
              .getAttribute('class').then(helpers.assertUnChecked)
          })

          bdd.it('should not toggle on enter', function() {
            return checkbox
              .getAttribute('class').then(helpers.assertUnChecked)
              .type("").sleep(250)
              .getAttribute('class').then(helpers.assertUnChecked)
          })

          bdd.it('should not toggle on space', function() {
            return checkbox
              .getAttribute('class').then(helpers.assertUnChecked)
              .type("").sleep(250)
              .getAttribute('class').then(helpers.assertUnChecked)
          })
        });

        bdd.describe('Disabled', function() {
          var checkbox;

          bdd.beforeEach(function() {
            checkbox = helpers
              .getElement(this.remote, `td:nth-child(3) ${type}`)
          });

          bdd.it('should not toggle on click', function() {
            return checkbox
              .getAttribute('class').then(helpers.assertUnChecked)
              .click().sleep(250)
              .getAttribute('class').then(helpers.assertUnChecked)
          })

          bdd.it('should not be focusable', function() {
            return checkbox
              .type("").catch(function(error){
                assert.match(error.toString(), new RegExp("cannot focus element"))
              })
          })
        });
      })
    })
  })
})
