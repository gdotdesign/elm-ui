Elm.Native.Browser = {};
Elm.Native.Browser.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.Browser = elm.Native.Browser || {};
  if (elm.Native.Browser.values) { return elm.Native.Browser.values; }

  if(typeof HTMLElement === "function") {
    /* Add dimensions property to HTMLElement so we can decode it, it's not
       exposed so it won't conflict with anything hopefully. */
    Object.defineProperty(HTMLElement.prototype, "dimensions", {
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
    Object.defineProperty(HTMLElement.prototype, "ontransitionend", {
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

  function focusEnd(object) {
    if(object.properties) object.properties["afocus"] = new MutableFocusHook(true)
    if(object._0) object._0.properties["afocus"] = new MutableFocusHook(true)
    return object;
  }

  function focus(object){
    if(object.properties) object.properties["afocus"] = new MutableFocusHook
    if(object._0) object._0.properties["afocus"] = new MutableFocusHook
    return object;
  }

  /* Blurs the active element. */
  function blur(x){
    document.activeElement && document.activeElement.blur();
    return x;
  }

  /* Interface. */
  return elm.Native.Browser.values = {
    toFixed: F2(function(value,decimals) { return value.toFixed(decimals) }),
    open: F2(function(url,value) { window.open(url); return value; }),
    rem: F2(function(a,b){ return a % b }),
    focusEnd: focusEnd,
    focus: focus,
    blur: blur,
  };
};
