var _gdotdesign$elm_ui$Native_Browser = function() {

  function delay(duration){
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      setTimeout(function(){
        return callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
      }, duration)
    })
  }

  function redirect(url, value) {
    window.location.href = url
    return value
  }

  function alert(message, value) {
    window.alert(message)
    return value
  }

  function openWindow(url,value) {
    window.open(url)
    return value
  }

  return {
    toFixed: F2(function(value,decimals) { return value.toFixed(decimals) }),
    rem: F2(function(a,b){ return a % b }),
    openWindow: F2(openWindow),
    redirect: F2(redirect),
    log: function(value) { console.log(value); return value;},
    alert: F2(alert),
    delay: delay
  }
}()
