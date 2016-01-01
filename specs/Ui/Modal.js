define([
  'intern!bdd',
  'intern/chai!assert',
  'specs/helpers'
], function(bdd, assert, helpers) {
  bdd.describe('Ui.App', function() {
    var button;

    bdd.beforeEach(function() {
      button = helpers
        .getElement(this.remote, 'tr:nth-child(7) ui-icon-button')
    })

    bdd.it('clicking on button the modal should open', function() {
      return button
        .click()
        .end()
        .findByCssSelector('.ui-modal-open')
        .isDisplayed(assert.ok)
    })

    bdd.it('clicking on backdrop sould close the modal', function() {
      return button
        .click()
        .end()
        .findByCssSelector('.ui-modal-open')
        .findByCssSelector('ui-modal-backdrop')
        .moveMouseTo(28, 49)
        .clickMouseButton(0)
        .end()
        .end()
        .findByCssSelector('ui-modal:not(.ui-modal-open)')
    })

    bdd.it('clicking on close icon sould close the modal', function() {
      return button
        .click()
        .end()
        .findByCssSelector('.ui-modal-open')
        .findByCssSelector('ui-icon')
        .click()
        .end()
        .end()
        .findByCssSelector('ui-modal:not(.ui-modal-open)')
    })
  })
})
