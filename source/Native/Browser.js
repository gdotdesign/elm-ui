var _gdotdesign$elm_ui$Native_Browser = function() {
  var scheduler = _elm_lang$core$Native_Scheduler
  var zeroTuple = _elm_lang$core$Native_Utils.Tuple0

  /* Redirect the user to the given url */
  function redirect(url) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      window.location.href = url
      return callback(scheduler.succeed(zeroTuple))
    })
  }

  /* Show an alert dialog */
  function alert(message) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      window.alert(message)
      return callback(scheduler.succeed(zeroTuple))
    })
  }

  /* Open a new window with the given URL */
  function openWindow(url) {
    return scheduler.nativeBinding(function(callback){
      var win = window.open(url)
      if(!win || win.closed || typeof win.closed=='undefined'){
        return callback(scheduler.fail("Window blocked!"))
      }else{
        return callback(scheduler.succeed(zeroTuple))
      }
    })
  }

  function setTitle(value){
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      document.title = value
      return callback(scheduler.succeed(zeroTuple))
    })
  }

  /* Interface */
  return {
    location: function(){ return window.location },
    openWindow: openWindow,
    setTitle: setTitle,
    redirect: redirect,
    alert: alert
  }
}()
