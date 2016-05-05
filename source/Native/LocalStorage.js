var _gdotdesign$elm_ui$Native_LocalStorage = function() {
  var Scheduler = _elm_lang$core$Native_Scheduler
  var isChromeApp = window.chrome && window.chrome.storage

  /* Gets a value from the localStorage as a result. */
  function get(key){
    return Scheduler.nativeBinding(function(callback){

      if(isChromeApp) {
        chrome.storage.local.get(key, function(data){
          if(data[key]) {
            callback(Scheduler.succeed(data[key]))
          } else {
            callback(Scheduler.fail("Key does not exsists in local storage!"))
          }
        })
      } else {
        var result = window.localStorage.getItem(key)
        if(result) {
          callback(Scheduler.succeed(result))
        } else {
          callback(Scheduler.fail("Key does not exsists in local storage!"))
        }
      }

    })
  }

  /* Sets a value to the localStoraget as a result. */
  function set(key, value){
    return Scheduler.nativeBinding(function(callback){

      if(isChromeApp) {
        obj = {}
        obj[key] = value
        chrome.storage.local.set(obj,function(){
          callback(Scheduler.succeed(""))
        })
      } else {
        try {
          window.localStorage.setItem(key, value)
          return callback(Scheduler.succeed(value))
        } catch (e) {
          return callback(Scheduler.fail("Could not write to local storage!"))
        }
      }

    })
  }

  /* Removes a value from the localStorage as a result. */
  function remove(key) {
    return Scheduler.nativeBinding(function(callback){
      if(isChromeApp) {
        chrome.storage.local.remove(key,function(){
          callback(Scheduler.succeed(""))
        })
      } else {
        try {
          window.localStorage.removeItem(key)
          return callback(Scheduler.succeed(key))
        } catch (e) {
          return callback(Scheduler.fail("Could not delete given key from local storage!"))
        }
      }
    })
  }

  /* Interface. */
  return {
    remove: remove,
    set: F2(set),
    get: get
  }
}()
