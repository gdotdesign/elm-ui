Elm.Native.Browser = {};
Elm.Native.Browser.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.Browser = elm.Native.Browser || {};
  if (elm.Native.Browser.values) { return elm.Native.Browser.values; }

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
        return this.querySelector('ui-dropdown') ||
               this.parentElement.querySelector('ui-dropdown')
               fallbackMenu
      }
    })

    /* Add dimensions property to HTMLElement so we can decode it, it's not
       exposed so it won't conflict with anything hopefully. */
    Object.defineProperty(element.prototype, "dimensions", {
      configurable: false,
      enumerable: false,
      writeable: false,
      get: function() {
        var rect = this.getBoundingClientRect()
        /* Offset values with scroll positions. */
        return { bottom: rect.bottom + window.pageYOffset,
                 right: rect.right + window.pageXOffset,
                 left: rect.left + window.pageXOffset,
                 top: rect.top + window.pageYOffset,
                 height: rect.height,
                 width: rect.width
               }
       }
    })

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

  /* Focus an element and place the cursor at the end of it's text. */
  function moveCursorToEnd(el) {
    el.focus();
    if (typeof el.selectionStart == "number") {
      el.selectionStart = el.selectionEnd = el.value.length;
    } else if (typeof el.createTextRange != "undefined") {
      var range = el.createTextRange();
      range.collapse(false);
      range.select();
    }
  }

  /* Focus hook for VirtualDom. */
  function MutableFocusHook(selectEnd) { this.selectEnd = selectEnd }
  MutableFocusHook.prototype.hook = function (node) {
    setTimeout(function () {
      if (document.activeElement !== node) {
        if (this.selectEnd) {
          moveCursorToEnd(node);
        } else {
          node.focus();
        }
      }
    }.bind(this));
  };

  function focus(object){
    if(object.properties) object.properties["afocus"] = new MutableFocusHook
    if(object._0) object._0.properties["afocus"] = new MutableFocusHook
    return object;
  }

  var Task = Elm.Native.Task.make(elm);
  var Utils = Elm.Native.Utils.make(elm);

  function focusTask(selector){
    return Task.asyncFunction(function(callback) {
      setTimeout(function(){
        var element = document.querySelector(selector)
        if(element){ element.focus() }
        return callback(Task.succeed(Utils.Tuple0));
      }, 30)
    });
  }

  /* Blurs the active element. */
  function blur(x){
    document.activeElement && document.activeElement.blur();
    return x;
  }

  function alertWindow(message, returnValue) {
    window.alert(message);
    return returnValue;
  }

  function haveSelector(selector) {
    return !!document.querySelector(selector)
  }

  function crash(expected, actual) {
    throw new Error(
      'expecting ' + expected + ' but got ' + actual
    );
  }

  function elementQueryDecoder(method, selector, decoder) {
    return function(value) {
      if (value instanceof HTMLElement) {
        var element = value[method](selector);
        if(element){
          return decoder(element)
        } else {
          throw new Error('Could not find selector: ' + selector)
        }
      } else {
        crash('a HTMLElement', value);
      }
    };
  }

  function closest(selector, decoder) {
    return elementQueryDecoder('closest', selector, decoder)
  }

  function atElement(selector, decoder) {
    return elementQueryDecoder('querySelector', selector, decoder)
  }

  /* Interface. */
  return elm.Native.Browser.values = {
    redirect: F2(function(url,value) { window.location.href = url; return value; }),
    toFixed: F2(function(value,decimals) { return value.toFixed(decimals) }),
    open: F2(function(url,value) { window.open(url); return value; }),
    rem: F2(function(a,b){ return a % b }),
    patchHTMLElement: patchHTMLElement,
    haveSelector: haveSelector,
    atElement: F2(atElement),
    alert: F2(alertWindow),
    focusTask: focusTask,
    closest: F2(closest),
    focus: focus,
    blur: blur
  };
};

/* CLOSEST POLYFILL */
(function (ELEMENT) {
  ELEMENT.matches = ELEMENT.matches || ELEMENT.mozMatchesSelector || ELEMENT.msMatchesSelector || ELEMENT.oMatchesSelector || ELEMENT.webkitMatchesSelector;

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
