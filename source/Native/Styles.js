var _gdotdesign$elm_ui$Native_Styles = function() {
  var theme = {}
  var currentStyles = {}

  var setVariables = function(vars) {
    var varsArray = _elm_lang$core$Native_List.toArray(vars)
    varsArray.forEach(function(obj){
      var key = obj._0
      var value = obj._1
      theme[key] = value
    })

    document.querySelectorAll('style[id]').forEach(function(element){
      if (!element.raw) { return }
      element.innerHTML = replaceVars(element.raw)
    })
  }

  if(window.MutationObserver) {
    new MutationObserver(function (mutations) {
      patchStyles()
    }).observe(document.body, { childList: true, subtree: true });
  } else {
    var patch = function(){
      patchStyles()
      if(document.querySelector('[class^=container-]')) { return }
      requestAnimationFrame(patch)
    }
    requestAnimationFrame(patch)
  }

  function replaceVars(string){
    var result = string
    for(var key in theme) {
      var value = theme[key]
      result = result.replace('var(--' + key + ')', value)
    }
    return result
  }

  function patchStyles(){
    var currentNode
    var tags = {}
    var iterator =
      document
        .createNodeIterator(document.documentElement, NodeFilter.SHOW_ELEMENT)

    var nextStyles = {}

    while(currentNode = iterator.nextNode()) {
      if (!currentNode.__styles) { continue }
      if (nextStyles[currentNode.__styles.id]) { continue }
      nextStyles[currentNode.__styles.id] = currentNode.__styles.value
    }

    for(var id in nextStyles) {
      if(currentStyles[id]) {
        nextStyles[id] = currentStyles[id]
        delete currentStyles[id]
      } else {
        var style = document.createElement('style')
        style.raw = nextStyles[id]
        style.innerHTML = replaceVars(nextStyles[id])
        style.setAttribute('id', id)
        document.head.appendChild(style)
        nextStyles[id] = style
      }
    }

    for(var id in currentStyles) {
      currentStyles[id].remove()
    }

    currentStyles = nextStyles
  }

  /* Interface */
  return {
    setVariables: setVariables
  }
}()
