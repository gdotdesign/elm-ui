module.exports = {
  before: function(client){
    this.page = client.page.page().navigate()
    this.section = this.page.section.calendar
  },

  beforeEach: function(client){
    client.refresh()
  },

  after: function(client){
    client.end()
  },

  'Calendar should have 42 cells': function(){
    this.section
      .verify.elementPresent('ui-calendar-cell:nth-of-type(42)')
  },

  'Calendar should show the year and month': function(){
    this.section
      .verify.containsText('ui-container div', '2015 - May')
  },

  'Calendar should change month when clicking on the next icon': function(){
    this.section
      .verify.containsText('@title', '2015 - May')
      .click('@nextIcon')
      .verify.containsText('@title', '2015 - June')
  },

  'Calendar should change month when clicking on the previous icon': function(){
    this.section
      .verify.containsText('@title', '2015 - May')
      .click('@prevIcon')
      .verify.containsText('@title', '2015 - April')
  },

  'Calendar should have selected date': function(){
    this.section
      .verify.elementPresent('@selected')
  },

  'Calendar should select date when clicked': function(){
    this.section
      .verify.containsText('@selected', "1")
      .click('@nextSelected')
      .verify.containsText('@selected', "16")
  },

  'Calendar should not select inactive date when clicked': function(){
    this.section
      .verify.containsText('@selected', "1")
      .click('@disabledCell')
      .verify.containsText('@selected', "1")
  }
}
