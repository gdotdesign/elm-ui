var util = require('util')

exports.assertion = function(selector, attribute) {
	var DEFAULT_MSG = 'Testing if attribute %s of <%s> exists.'
	var MSG_ELEMENT_NOT_FOUND = DEFAULT_MSG + ' ' + 'Element could not be located.'

  this.message = util.format(DEFAULT_MSG, attribute, selector)

  this.expected = null

  this.pass = function(value) {
  	return !value
  }

  this.failure = function(result) {
    var failed = (result === false) ||
      result && (result.status === -1)

    if (failed) {
      this.message = util.format(MSG_ELEMENT_NOT_FOUND, attribute, selector);
    }
    return failed;
  };

  this.value = function(result) {
  	return result.value
  }

  this.command = function(callback) {
  	return this.api.getAttribute(selector, attribute, callback)
  }

}
