var _gdotdesign$elm_ui$Native_Vendor = function() {
  /* http://davidwalsh.name/vendor-prefix */
  var styles = window.getComputedStyle(document.documentElement, '')

  var vendorPrefix = (Array.prototype.slice
    .call(styles)
    .join('')
    .match(/-(moz|webkit|ms)-/) || (styles.OLink === '' && ['', 'o'])
  )[1]

  /* Interface */
  return {
  	prefix: vendorPrefix
  }
}()
