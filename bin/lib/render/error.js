var fs = require('fs')
var hljs = require('highlight.js')

var htmlErrorContent = `
<html>
  <style>
    body {
      all: unset;
    }

    .error {
      margin-bottom: 20px;
      padding-bottom: 20px;
      border-bottom: 1px solid rgba(0,0,0,0.1);
    }

    .error pre {
      border: 1px solid rgba(0,0,0,0.1);
      line-height: 18px;
      background: #F9F9F9;
      padding: 10px;
    }

    .error p {
      white-space: pre;
    }

    .elm-error {
      all: unset;

      box-sizing: boder-box;
      overflow-y: scroll;
      font-family: sans;
      position: fixed;
      color: #333;
      bottom: 0;
      right: 0;
      left: 0;
      top: 0;
    }

    .elm-error > div {
      padding: 40px;
      max-width: 960px;
      margin: 0 auto;
    }

    h2 {
      font-size: 24px;
      margin: 0;
      margin-bottom: 30px;
    }

    /* Base16 Atelier Forest Light - Theme */
    /* by Bram de Haan (http://atelierbram.github.io/syntax-highlighting/atelier-schemes/forest) */
    /* Original Base16 color scheme by Chris Kempson (https://github.com/chriskempson/base16) */

    /* Atelier-Forest Comment */
    .hljs-comment,
    .hljs-quote {
      color: #766e6b;
    }

    /* Atelier-Forest Red */
    .hljs-variable,
    .hljs-template-variable,
    .hljs-attribute,
    .hljs-tag,
    .hljs-name,
    .hljs-regexp,
    .hljs-link,
    .hljs-name,
    .hljs-selector-id,
    .hljs-selector-class {
      color: #f22c40;
    }

    /* Atelier-Forest Orange */
    .hljs-number,
    .hljs-meta,
    .hljs-built_in,
    .hljs-builtin-name,
    .hljs-literal,
    .hljs-type,
    .hljs-params {
      color: #df5320;
    }

    /* Atelier-Forest Green */
    .hljs-string,
    .hljs-symbol,
    .hljs-bullet {
      color: #7b9726;
    }

    /* Atelier-Forest Blue */
    .hljs-title,
    .hljs-section {
      color: #407ee7;
    }

    /* Atelier-Forest Purple */
    .hljs-keyword,
    .hljs-selector-tag {
      color: #6666ea;
    }

    .hljs {
      display: block;
      overflow-x: auto;
      background: #f1efee;
      color: #68615e;
      padding: 0.5em;
    }

    .hljs-emphasis {
      font-style: italic;
    }

    .hljs-strong {
      font-weight: bold;
    }
  </style>
  <div class='elm-error'>
    <div>
      <h2>TITLE</h2>
      <div>ERROR</div>
    </div>
  </div>
</html>
`.replace(/\n/g, '')

var renderError = function(error) {
  var code =
    fs.readFileSync(error.file, 'utf-8')
      .split(/\n/)
      .slice(error.region.start.line - 3, error.region.end.line + 2)
      .join("\n")

  console.log(error)

  return `
  <div class="error">
    <strong>
      <span>${error.tag} - </span>
      ${error.overview}
    </strong>
    <pre>${hljs.highlight("elm", code).value}</pre>
    <p>${error.details}</p>
  </div>
  `.replace(/\"/g, "\\\"")
  .replace(/\n/g, "\\n")
}

var renderHTMLError = function(title, content) {
  console.log(content)
  var errors =
    JSON
      .parse(content)
      .map(function(error){
        return renderError(error)
      })
      .join("")

  var errorContent = htmlErrorContent
    .replace('TITLE', title)
    .replace('ERROR', errors)

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
