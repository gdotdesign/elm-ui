var renderHtml = require('../render/html')
var path = require('path')
var fs = require('fs')

module.exports = function() {
	var destination = path.resolve('dist/index.html')

	return function(callback) {
		console.log('Building HTML...')

		fs.writeFileSync(destination, renderHtml())

		callback(null, null)
	}
}
