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

  'Enabled checkbox should have tab index': function(){
    this.page
      .verify.attributeEquals('@checkbox', 'tabindex', '0')
  },

  'Enabled checkbox should toggle on click': function(){
    this.page
      .verify.cssClassNotPresent('@checkbox', 'checked')
      .click('@checkbox')
      .verify.cssClassPresent('@checkbox', 'checked')
  },

  'Enabled checkbox should toggle on enter': function(){
    this.page
      .verify.cssClassNotPresent('@checkbox', 'checked')
      .setValue('@checkbox', '')
      .verify.cssClassPresent('@checkbox', 'checked')
  },

  'Enabled checkbox should toggle on space': function(){
    this.page
      .verify.cssClassNotPresent('@checkbox', 'checked')
      .setValue('@checkbox', '')
      .verify.cssClassPresent('@checkbox', 'checked')
  },

  'Readonly checkbox should have tab index': function(){
    this.page
      .verify.attributeEquals('@readonlyCheckbox', 'tabindex', '0')
  },

  'Readonly checkbox should not toggle on click': function(){
    this.page
      .verify.cssClassNotPresent('@readonlyCheckbox', 'checked')
      .click('@readonlyCheckbox')
      .verify.cssClassNotPresent('@readonlyCheckbox', 'checked')
  },

  'Readonly checkbox should not toggle on enter': function(){
    this.page
      .verify.cssClassNotPresent('@readonlyCheckbox', 'checked')
      .setValue('@readonlyCheckbox', '')
      .verify.cssClassNotPresent('@readonlyCheckbox', 'checked')
  },

  'Readonly checkbox should not toggle on space': function(){
    this.page
      .verify.cssClassNotPresent('@readonlyCheckbox', 'checked')
      .setValue('@readonlyCheckbox', '')
      .verify.cssClassNotPresent('@readonlyCheckbox', 'checked')
  },

  'Disabled checkbox should not have tab index': function(){
    this.page
      .verify.notToHaveAttribute('@disabledCheckbox', 'tabindex')
  },

  'Disabled checkbox should not toggle on click': function(){
    this.page
      .verify.cssClassNotPresent('@disabledCheckbox', 'checked')
      .click('@disabledCheckbox')
      .verify.cssClassNotPresent('@disabledCheckbox', 'checked')
  },
}
