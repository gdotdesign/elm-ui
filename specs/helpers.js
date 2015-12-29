define(['intern/chai!assert'], function(assert) {
  return {
    getElement: function(remote, selector) {
      return remote
      .setFindTimeout(10000)
      .get(require.toUrl('dist/index.html'))
      .findByCssSelector(selector)
    },
    assertAlert: function(command){
      return command
        .end()
        .findByCssSelector('clicked')
        .waitForDeletedByCssSelector('clicked')
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
      assert.match(value, /^0\.6/)
    }
  }
})
