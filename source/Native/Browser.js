var _gdotdesign$elm_ui$Native_Browser = function() {

  function patchHTMLElement(element) {
    /* Add ontransitionend property to use virtual node attributes. Maybe this
       needs a better implementation. */
    Object.defineProperty(element.prototype, "ontransitionend", {
      configurable: false,
      enumerable: false,
      writeable: false,
      set: function(handler) {
        var wrap = function(event) {
          /* Don't forward bubbled events from children. */
          if(event.target != this) return;
          handler.call(event)
        }.bind(this)

        /* Remove old handler if present. */
        if (this._ontransitionend_hadler) {
          this.removeEventListener('transitionend', this._ontransitionend_hadler)
          this._ontransitionend_hadler = null
        }

        /* Add event listener. */
        this.addEventListener('transitionend', wrap)
        this._ontransitionend_hadler = wrap
      }
    })
  }

  if(typeof window !== 'undefined' && window.HTMLElement) {
    patchHTMLElement(window.HTMLElement)
  }

  function focus(selector){
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      setTimeout(function(){
        var element = document.querySelector(selector)
        if(element){ element.focus() }
        return callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
      }, 30)
    })
  }

  function focusUid(uid) {
    return focus("[uid='" + uid + "']")
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

  return {
    boundingClientRectDecoder: F2(elementQueryDecoder('getBoundingClientRect', '')),
    toFixed: F2(function(value,decimals) { return value.toFixed(decimals) }),
    rem: F2(function(a,b){ return a % b }),
    focusUid: focusUid,
    delay: delay,
    focus: focus
  }
}()
