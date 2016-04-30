var _gdotdesign$elm_ui$Native_Dom = function() {

  var Json = _elm_lang$core$Native_Json;
  var valueDecoder = Json.decodePrimitive("value")

  function focusSelector(selector){
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      setTimeout(function(){
        var element = document.querySelector(selector)
        if(element){ element.focus() }
        return callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
      }, 30)
    })
  }

  /* TODO: When fixed in *core* return an "Err Result" */
  function fail(msg){
    var faliure = Json.fail(msg)
    faliure._0 = {}
    return faliure
  }

  function decodeElementFunction(method, selector, decoder) {
    return Json.customAndThen(valueDecoder)(function(value){
      if (value instanceof HTMLElement) {
        var element = value[method](selector);
        if(element){
          return Json.run(decoder)(element)
        } else {
          return fail('Could not find selector: ' + selector)
        }
      } else {
        return fail('Not HTML Element!')
      }
    })
  }

  return {
    decodeElementFunction: F3(decodeElementFunction),
    focusSelector: focusSelector
  }
}();

/* Polyfills */
(function(){
  Element.prototype.nearest = function(selector){
    return this.closest(selector) || // parent
           this.parentElement.querySelector(selector) // child or neighbor
  }

  if (typeof Element.prototype.matches !== 'function') {
    Element.prototype.matches = Element.prototype.msMatchesSelector || Element.prototype.mozMatchesSelector || Element.prototype.webkitMatchesSelector || function matches(selector) {
      var element = this;
      var elements = (element.document || element.ownerDocument).querySelectorAll(selector);
      var index = 0;

      while (elements[index] && elements[index] !== element) {
        ++index;
      }

      return Boolean(elements[index]);
    };
  }

  if (typeof Element.prototype.closest !== 'function') {
    Element.prototype.closest = function closest(selector) {
      var element = this;

      while (element && element.nodeType === 1) {
        if (element.matches(selector)) {
          return element;
        }

        element = element.parentNode;
      }

      return null;
    };
  }
})()
