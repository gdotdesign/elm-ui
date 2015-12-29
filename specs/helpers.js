define(['intern/chai!assert'], function(assert) {
  return {
    getElement: function(remote, selector) {
      return remote
      .get(require.toUrl('dist/index.html'))
      .findByCssSelector(selector)
    },
    assertAlert: function(command){
      return command
        .sleep(250)
        .getAlertText()
        .then(function(value){
          assert.equal(value, 'Clicked!')
        })
        .acceptAlert()
    },
    assertChecked: function(value) {
      assert.equal(value, "checked")
    },
    assertUnchecked: function(value) {
      assert.equal(value, "")
    },
    assertTabindex: function(value) {
      assert.equal(value, '0');
    },
    assertNotAllowed: function(value) {
      assert.equal(value, 'not-allowed')
    },
    assertDisabledOpacity: function(value) {
      assert.equal(value, '0.6')
    }
  }
})
