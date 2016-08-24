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

  'Left sided icon button text should have left margin': function(client){
    client
      .verify.cssProperty('ui-icon-button.ui-button-secondary span', 'margin-left', '10px')
  },

  'Right sided icon button icon should have left margin': function(client){
    client
      .verify.cssProperty('ui-icon-button.ui-button-success ui-icon', 'margin-left', '10px')
  },

  'Icon button without text should not have any margin': function(client){
    client
      .verify.cssProperty('ui-icon-button.ui-button-primary.ui-button-medium', 'width', '54px')
  }
}
