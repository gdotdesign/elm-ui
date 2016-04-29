var _gdotdesign$elm_ui$Native_Number = function() {

  /* Formats a number using fixed-point notation */
  function toFixed(value, decimals) {
    return value.toFixed(decimals)
  }

  /* Return remainder */
  function rem(a, b) {
    return a % b
  }

  /* Interface */
  return {
    toFixed: F2(toFixed),
    rem: F2(rem),
  }
}()
