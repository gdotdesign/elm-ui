define([
  'intern!bdd',
  'intern/chai!assert',
  'specs/helpers'
], function (bdd, assert, helpers) {
  bdd.describe('Ui.Checkbox', function(){

    ['ui-checkbox',
     'ui-checkbox-toggle',
     'ui-checkbox-radio'
    ].forEach(function(type){
      bdd.describe(type,function(){
        bdd.describe('Enabled', function(){
          var checkbox;

          bdd.before(function(){
            checkbox = helpers
              .getElement(this.remote, `td ${type}`)
          })

          bdd.it('should have tabindex', function () {
            return checkbox
              .getAttribute('tabindex')
              .then(helpers.assertTabindex)
          });

          bdd.it('should toggle on click', function(){
            return checkbox
              .getAttribute('class').then(helpers.assertUnChecked)
              .click().sleep(250)
              .getAttribute('class').then(helpers.assertChecked)
          })

          bdd.it('should toggle on enter', function(){
            return checkbox
              .getAttribute('class').then(helpers.assertChecked)
              .type("").sleep(250)
              .getAttribute('class').then(helpers.assertUnChecked)
          })

          bdd.it('should toggle on space', function(){
            return checkbox
              .getAttribute('class').then(helpers.assertUnChecked)
              .type("").sleep(250)
              .getAttribute('class').then(helpers.assertChecked)
          })
        })
      })
    })
  })
})
