var ansi_up = require('ansi_up')

var htmlErrorContent = `
<html>
  <style>
    div.elm-error {
      overflow-y: scroll;
      font-family: sans;
      position: fixed;
      padding: 40px;
      color: #333;
      bottom: 0;
      right: 0;
      left: 0;
      top: 0;
    }

    h2 {
      font-size: 24px;
      margin: 0;
    }
  </style>
  <div class='elm-error'>
    <h2>TITLE</h2>
    <pre>ERROR</pre>
  </div>
</html>
`.replace(/\n/g, '')

var renderHTMLError = function(title, content) {
  var formattedContent =
    ansi_up
    .ansi_to_html(content)
    .replace(/\\/g, '\\\\')
    .replace(/"/g, '\\"')
    .split("\n")
    .filter(function(line) {
      return !line.match(/^\[/)
    })
    .join("\n")
    .trim()
    .replace(/\n/g, "\\n")

  var errorContent = htmlErrorContent
    .replace('TITLE', title)
    .replace('ERROR', formattedContent)

  return `document.write("${errorContent}")`
}

var renderCSSError = function(title, content) {
  var formattedContent =
    content.replace(/\n/g, "\\A").replace(/"/g, '\\"')

  return `
    body::before {
      font-family: sans-serif;
      content: "${title}";
      font-weight: bold;
      background: white;
      position: fixed;
      font-size: 24px;
      padding: 40px;
      color: #333;
      right: 0;
      left: 0;
      top: 0;
    }

    body::after {
      content: "${formattedContent}";
      font-family: monospace;
      background: white;
      line-height: 25px;
      white-space: pre;
      position: fixed;
      font-size: 13px;
      display: block;
      color: #333;
      top: 90px;
      bottom: 0;
      right: 0;
      left: 0;
      padding: 40px;
      padding-top: 0;
    }
  `
}

module.exports = {
  renderHTMLError: renderHTMLError,
  renderCSSError: renderCSSError
}
