var _gdotdesign$elm_ui$Native_Number = function() {

  function toFixed(value, decimals) {
    return value.toFixed(decimals)
  }

  function rem(a, b) {
    return a % b
  }

  return {
    toFixed: F2(toFixed),
    rem: F2(rem),
  }
}()
