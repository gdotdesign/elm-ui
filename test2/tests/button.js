module.exports = {
  before: function(client){
    this.page = client.page.page().navigate()
  },

  beforeEach: function(client){
    client.refresh()
  },

  after: function(client){
    client.end()
  },

  'Enabled button has tab index' : function() {
    this.page
      .verify.attributeEquals('@button', 'tabindex', '0')
  },

  'Enabled button triggers message on click': function(){
    this.page
      .verify.elementNotPresent('clicked')
      .click('@button')
      .waitForElementVisible('clicked')
      .verify.elementPresent('clicked')
  },

  'Enabled button triggers message on space': function(){
    this.page
      .verify.elementNotPresent('clicked')
      .setValue('@button','')
      .waitForElementVisible('clicked')
      .verify.elementPresent('clicked')
  },

  'Enabled button triggers message on enter': function(){
    this.page
      .verify.elementNotPresent('clicked')
      .setValue('@button','')
      .waitForElementVisible('clicked')
      .verify.elementPresent('clicked')
  },

  "Disabled button doesn't have tab index": function(){
    this.page
      .verify.notToHaveAttribute('@disabledButton', 'tabindex')
  },

  "Disabled button doesn't trigger message on click": function(){
    this.page
      .verify.elementNotPresent('clicked')
      .click('@disabledButton')
      .waitForElementNotPresent('clicked')
      .verify.elementNotPresent('clicked')
  },

  "Disabled button doesn't trigger message on space": function(){
    this.page
      .verify.elementNotPresent('clicked')
      .setValue('@disabledButton','')
      .waitForElementNotPresent('clicked')
      .verify.elementNotPresent('clicked')
  },

  "Disabled button doesn't trigger message on enter": function(){
    this.page
      .verify.elementNotPresent('clicked')
      .setValue('@disabledButton','')
      .waitForElementNotPresent('clicked')
      .verify.elementNotPresent('clicked')
  },

  "Disabled button should have disabled state": function(){
    this.page
      .verify.cssProperty('@disabledButton', 'opacity', '0.6')
  }
}
