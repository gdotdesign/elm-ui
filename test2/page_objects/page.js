var path = require('path')

module.exports = {
  url: 'file://' + path.resolve('dist/index.html'),
  elements: {
  	app: {
  		selector: 'ui-app'
  	},
    checkbox: {
      selector: 'td ui-checkbox'
    },
    disabledCheckbox: {
      selector: 'td ui-checkbox.disabled'
    },
    readonlyCheckbox: {
      selector: 'td ui-checkbox.readonly'
    },
  	disabledButton: {
  		selector: 'td ui-button.disabled'
  	},
    button: {
      selector: 'td ui-button.ui-button-big.ui-button-primary'
    },
  },
  sections: {
    calendar: {
      selector: 'td:first-child ui-calendar',
      elements: {
        title: {
          selector: 'ui-container div'
        },
        disabledCell: {
          selector: 'ui-calendar-cell:nth-child(1)'
        },
        nextSelected: {
          selector: 'ui-calendar-cell:nth-of-type(20)'
        },
        selected: {
          selector: 'ui-calendar-cell.selected'
        },
        prevIcon: {
          selector: '.ion-chevron-left'
        },
        nextIcon:{
          selector: '.ion-chevron-right'
        }
      }
    }
  }
}
