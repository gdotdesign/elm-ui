Object.defineProperty(HTMLElement.prototype, "dimensions", {
  writeable: false,
  enumerable: false,
  configurable: false,
  get: function() {
    var rect = this.getBoundingClientRect()
    return { top: rect.top + window.pageYOffset,
             left: rect.left + window.pageXOffset,
             right: rect.right + window.pageXOffset,
             bottom: rect.bottom + window.pageYOffset,
             height: rect.height,
             width: rect.width
           }
   }
})

Object.defineProperty(HTMLElement.prototype, "ontransitionend", {
  writeable: false,
  enumerable: false,
  configurable: false,
  set: function(handler) {
    var h = function(event) {
      if(event.target != this) return;
      handler.call(event)
    }.bind(this)

    if (this._ontransitionend_hadler) {
      this.removeEventListener('transitionend', this._ontransitionend_hadler)
      this._ontransitionend_hadler = null
    }
    this.addEventListener('transitionend', h)
    this._ontransitionend_hadler = h
  }
})

Elm.Native.Browser = {};
Elm.Native.Browser.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.Browser = elm.Native.Browser || {};
  if (elm.Native.Browser.values) {
    return elm.Native.Browser.values;
  }

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

  function blur(x){
    document.activeElement && document.activeElement.blur();
    return x;
  }

  return Elm.Native.Browser.values = {
    blur: blur,
    focus: focus,
    focusEnd: focusEnd,
    toFixed: F2(function(value,decimals) { return value.toFixed(decimals) }),
    rem: F2(function(a,b){ return a % b })
  };
};
