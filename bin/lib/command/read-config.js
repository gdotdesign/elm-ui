var path = require('path')

module.exports = function(options) {
	var file = path.resolve(`config/${options.env}.json`)
	var data = {};

	try {
		data = require(file)
	} catch (e) {
		console.log("Error reading environment configuration:\n  > " + e)
	}

	return data;
}
