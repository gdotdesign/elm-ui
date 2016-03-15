Elm.Native.LocalStorage = {};
Elm.Native.LocalStorage.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.LocalStorage = elm.Native.LocalStorage || {};
  if (elm.Native.LocalStorage.values) {return elm.Native.LocalStorage.values; }

  var Task = Elm.Native.Task.make(elm);

  var isChromeApp = window.chrome && window.chrome.storage

  /* Gets a value from the localStorage as a result. */
  function get(key){
    if(isChromeApp) {
      return Task.asyncFunction(function(callback){
        chrome.storage.local.get(key, function(data){
          if(data[key]) {
            callback(Task.succeed(data[key]))
          } else {
            callback(Task.fail("Key does not exsists in local storage!"))
          }
        })
      })
    } else {
      result = window.localStorage.getItem(key);
      if(result) {
        return Task.succeed(result);
      } else {
        return Task.fail("Key does not exsists in local storage!");
      }
    }
  }

  /* Sets a value to the localStoraget as a result. */
  function set(key, value){
    if(isChromeApp) {
      return Task.asyncFunction(function(callback){
        obj = {}
        obj[key] = value
        chrome.storage.local.set(obj,function(){
          callback(Task.succeed(""))
        })
      })
    } else {
      try {
        window.localStorage.setItem(key, value);
        return Task.succeed(value);
      } catch (e) {
        return Task.fail("Could not write to local storage!")
      }
    }
  }

  /* Removes a value from the localStorage as a result. */
  function remove(key) {
    if(isChromeApp) {
      return Task.asyncFunction(function(callback){
        chrome.storage.local.remove(key,function(){
          callback(Task.succeed(""))
        })
      })
    } else {
      try {
        window.localStorage.removeItem(key);
        return Task.succeed(key);
      } catch (e) {
        return Task.fail("Could not delete given key from local storage!");
      }
    }
  }

  /* Interface. */
  return elm.Native.LocalStorage.values = {
    remove: remove,
    set: F2(set),
    get: get
  };
};
