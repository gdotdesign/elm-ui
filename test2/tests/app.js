module.exports = {
  'Ui.App' : function (client) {

    var page = client.page.page()

    page.navigate()
      .assert.attributeEquals('meta[name=viewport]', 'content', 'initial-scale=1.0, user-scalable=no')
      .assert.title('Elm-UI Kitchen Sink')
      .assert.visible('@app')
      .assert.elementPresent('title')

    client.end()
  }
}
