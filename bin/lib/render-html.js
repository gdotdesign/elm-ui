module.exports = function(config) {
  return `<html>
    <head>
    </head>
    <body style="overflow: hidden;margin:0;">
      <script>
        window.ENV = ${JSON.stringify(config)}
      </script>
      <script src='main.js' type='application/javascript'>
      </script>
      <script>Elm.fullscreen(Elm.Main);</script>
    </body>
  </html>`
}
