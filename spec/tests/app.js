module.exports = {
  'Ui.App' : function (client) {

    var page = client.page.page()

    page.navigate()
      .verify.attributeEquals('meta[name=viewport]', 'content', 'initial-scale=1.0, user-scalable=no')
      .verify.title('Elm-UI Kitchen Sink')
      .verify.visible('@app')
      .verify.elementPresent('title')

    client.end()
  }
}
