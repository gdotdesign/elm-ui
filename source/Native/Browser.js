var _gdotdesign$elm_ui$Native_Browser = function() {

  function patchHTMLElement(element) {
    var fallbackMenu = { getBoundingClientRect: function(){
        return { bottom: 0,
          height: 0,
          width: 0,
          right: 0,
          left: 0,
          top: 0
        }
      }
    }

    Object.defineProperty(element.prototype, "dropdown", {
      configurable: false,
      enumerable: false,
      writeable: false,
      get: function(){
        console.log(this)
        return this.querySelector('ui-dropdown') ||
               this.parentElement.querySelector('ui-dropdown')
               fallbackMenu
      }
    })
  }

  if(typeof window !== 'undefined' && window.HTMLElement) {
    patchHTMLElement(window.HTMLElement)
  }

  function focusSelector(selector){
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      setTimeout(function(){
        var element = document.querySelector(selector)
        if(element){ element.focus() }
        return callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
      }, 30)
    })
  }

  function delay(duration){
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      setTimeout(function(){
        return callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
      }, duration)
    })
  }

  var Json = _elm_lang$core$Native_Json;

  function elementQueryDecoder(method, selector) {
    return function (decoder1, decoder2) {
      return Json.customAndThen(decoder1)(function(value){
        if (value instanceof HTMLElement) {
          var element = value[method](selector);
          if(element){
            return Json.run(decoder2)(element)
          } else {
            return Json.fail('Could not find selector: ' + selector)
          }
        } else {
          return Json.badPrimitive('HTMLElement', element)
        }
      })
    }
  }

  function redirect(url, value) {
    window.location.href = url
    return value
  }

  function alert(message, value) {
    window.alert(message)
    return value
  }

  function openWindow(url,value) {
    window.open(url)
    return value
  }

  return {
    boundingClientRectDecoder: F2(elementQueryDecoder('getBoundingClientRect', '')),
    toFixed: F2(function(value,decimals) { return value.toFixed(decimals) }),
    rem: F2(function(a,b){ return a % b }),
    focusSelector: focusSelector,
    openWindow: F2(openWindow),
    redirect: F2(redirect),
    alert: F2(alert),
    delay: delay,
  }
}()
