define([
  'intern!bdd',
  'intern/chai!assert',
  'specs/helpers'
], function(bdd, assert, helpers) {
  bdd.describe('Ui.Calendar', function() {

    bdd.describe('Enabled', function() {
      var calendar;

      bdd.beforeEach(function() {
        calendar = helpers
          .getElement(this.remote, 'td:first-child ui-calendar')
      })
    })

    bdd.describe('Readonly', function() {
      var calendar;

      bdd.beforeEach(function() {
        calendar = helpers
          .getElement(this.remote, 'td:nth-child(2) ui-calendar')
      })

      bdd.it("should not display chevrons", function(){
        return calendar
          .findByCssSelector('.ion-chevron-left')
          .isDisplayed(assert.isFalse)
          .end()
          .findByCssSelector('.ion-chevron-right')
          .isDisplayed(assert.isFalse)
      })

      bdd.it("cells should not be clickable", function(){
        return calendar
          .findByCssSelector('ui-calendar-cell:nth-child(6)')
          .getProperty('onmousedown').then(assert.isNull)
      })
    })

    bdd.describe('Disabled', function() {
      var calendar;

      bdd.beforeEach(function() {
        calendar = helpers
          .getElement(this.remote, 'td:nth-child(3) ui-calendar.disabled')
      })

      bdd.it("chevrons should not be clickable", function(){
        return calendar
          .findByCssSelector('.ion-chevron-left')
          .getProperty('onmousedown').then(assert.isNull)
          .end()
          .findByCssSelector('.ion-chevron-right')
          .getProperty('onmousedown').then(assert.isNull)
      })

      bdd.it("cells should not be clickable", function(){
        return calendar
          .findByCssSelector('ui-calendar-cell:nth-child(6)')
          .getProperty('onmousedown').then(assert.isNull)
      })
    })
  })
})
