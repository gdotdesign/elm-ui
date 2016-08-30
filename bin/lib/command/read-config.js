var path = require('path')
var fs = require('fs')

module.exports = function(options) {
	var file = path.resolve(`config/${options.env}.json`)
	var data = {};

	try {
		data = JSON.parse(fs.readFileSync(file, 'utf-8'))
	} catch (e) {
		console.log("Error reading environment configuration:\n  > " + e)
	}

	return data;
}
