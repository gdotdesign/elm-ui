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

  function elementFunctionDecoder(method, selector, decoder) {
    return Json.customAndThen(valueDecoder)(function(value){
      if (value instanceof HTMLElement) {
        var element = value[method](selector);
        if(element){
          return Json.run(decoder)(element)
        } else {
          return Json.fail('Could not find selector: ' + selector)
        }
      } else {
        return { tag: 'primitive', type: 'HTMLElement', value: value };
      }
    })
  }

  return {
    elementFunctionDecoder: F3(elementFunctionDecoder),
    focusSelector: focusSelector
  }
}()

/* CLOSEST POLYFILL */
(function (ELEMENT) {
  ELEMENT.matches =
    ELEMENT.matches ||
    ELEMENT.mozMatchesSelector ||
    ELEMENT.msMatchesSelector ||
    ELEMENT.oMatchesSelector ||
    ELEMENT.webkitMatchesSelector;

  ELEMENT.closest = ELEMENT.closest || function closest(selector) {
    var element = this;

    while (element) {
      if (element.matches(selector)) {
        break;
      }

      element = element.parentElement;
    }

    return element;
  };
}(typeof Element == "function" && Element.prototype));
