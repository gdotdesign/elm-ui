var _gdotdesign$elm_ui$Native_Dom = function() {

  var Json = _elm_lang$core$Native_Json;
  var valueDecoder = Json.decodePrimitive("value")

  function blur(){
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      if(document.activeElement) { document.activeElement.blur() }
      return callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
    })
  }

  function decodeElementFunction(method, selector, decoder) {
    return Json.andThen(function(value){
      if (value instanceof HTMLElement) {
        var element = value[method](selector);
        if(element){
          var result = Json.run(decoder)(element)
          if(result.ctor == 'Ok'){
            return Json.succeed(result._0)
          } else {
            return Json.fail(result._0)
          }
        } else {
          return Json.fail('Could not find selector: ' + selector)
        }
      } else {
        return Json.fail('Not HTML Element!')
      }
    })(valueDecoder)
  }

  return {
    decodeElementFunction: F3(decodeElementFunction),
    blur: blur
  }
}();

/* Polyfills */
(function(){
  /* Add dimensions property to HTMLElement so we can decode it, it's not
     exposed so it won't conflict with anything hopefully. */
  Object.defineProperty(Element.prototype, "dimensions", {
    configurable: false,
    enumerable: false,
    writeable: false,
    value: function() {
      var rect = this.getBoundingClientRect()
      return { scrollLeft: window.pageXOffset,
               scrollTop: window.pageYOffset,
               bottom: rect.bottom,
               height: rect.height,
               width: rect.width,
               right: rect.right,
               left: rect.left,
               top: rect.top
             }
     }
  })

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
