var _gdotdesign$elm_ui$Native_Browser = function() {
  /* http://davidwalsh.name/vendor-prefix */
  var styles = window.getComputedStyle(document.documentElement, '')

  var vendorPrefix = (Array.prototype.slice
    .call(styles)
    .join('')
    .match(/-(moz|webkit|ms)-/) || (styles.OLink === '' && ['', 'o'])
  )[1]

  /* Redirect the user to the given url */
  function redirect(url, value) {
    window.location.href = url
    return value
  }

  /* Show an alert dialog */
  function alert(message, value) {
    window.alert(message)
    return value
  }

  /* Open a new window with the given URL */
  function openWindow(url,value) {
    window.open(url)
    return value
  }

  /* Interface */
  return {
    location: function(){ return window.location },
    openWindow: F2(openWindow),
    redirect: F2(redirect),
    prefix: vendorPrefix,
    alert: F2(alert)
  }
}()
