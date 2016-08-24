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
      .waitForElementVisible('@checkbox')
      .click('@checkbox')
      .waitForElementVisible('@checkedCheckbox')
  },

  'Enabled checkbox should toggle on enter': function(){
    this.page
      .waitForElementVisible('@checkbox')
      .setValue('@checkbox', '')
      .waitForElementVisible('@checkedCheckbox')
  },

  'Enabled checkbox should toggle on space': function(){
    this.page
      .waitForElementVisible('@checkbox')
      .setValue('@checkbox', '')
      .waitForElementVisible('@checkedCheckbox')
  },

  'Readonly checkbox should have tab index': function(){
    this.page
      .verify.attributeEquals('@readonlyCheckbox', 'tabindex', '0')
  },

  'Readonly checkbox should not toggle on click': function(){
    this.page
      .waitForElementVisible('@readonlyCheckbox')
      .click('@readonlyCheckbox')
      .waitForElementVisible('@readonlyCheckbox')
  },

  'Readonly checkbox should not toggle on enter': function(){
    this.page
      .waitForElementVisible('@readonlyCheckbox')
      .setValue('@readonlyCheckbox', '')
      .waitForElementVisible('@readonlyCheckbox')
  },

  'Readonly checkbox should not toggle on space': function(){
    this.page
      .waitForElementVisible('@readonlyCheckbox')
      .setValue('@readonlyCheckbox', '')
      .waitForElementVisible('@readonlyCheckbox')
  },

  'Disabled checkbox should not have tab index': function(){
    this.page
      .verify.notToHaveAttribute('@disabledCheckbox', 'tabindex')
  },

  'Disabled checkbox should not toggle on click': function(){
    this.page
      .waitForElementVisible('@disabledCheckbox')
      .click('@disabledCheckbox')
      .waitForElementVisible('@disabledCheckbox')
  },
}
