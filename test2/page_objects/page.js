var path = require('path')

module.exports = {
  url: 'file://' + path.resolve('dist/index.html'),
  elements: {
  	app: {
  		selector: 'ui-app'
  	},
  	disabledButton: {
  		selector: 'td ui-button.disabled'
  	},
    button: {
      selector: 'td ui-button.ui-button-big.ui-button-primary'
    }
  }
}
