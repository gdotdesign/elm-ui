var _gdotdesign$elm_ui$Native_Styles = function() {
  if(typeof document === "undefined") {
    return {patchStyles: function() {}, setVariables: function() {}};
  }

  var currentStyles = {}

  var setupObserver = function () {
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
  }

  if (document.body) {
    setupObserver()
  } else {
    document.addEventListener('DOMContentLoaded', setupObserver)
  }

  function setVariables(data){
    _elm_lang$core$Native_List.toArray(data).forEach(function(item){
      document.documentElement.style.setProperty &&
      document.documentElement.style.setProperty(item._0, item._1)
    })
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
        style.innerHTML = nextStyles[id]
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
    setVariables: setVariables,
    patchStyles: patchStyles
  }
}()
