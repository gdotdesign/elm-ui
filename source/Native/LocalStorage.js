Elm.Native.LocalStorage = {};
Elm.Native.LocalStorage.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.LocalStorage = elm.Native.LocalStorage || {};
  if (elm.Native.LocalStorage.values) {return elm.Native.LocalStorage.values; }

  var Result = Elm.Result.make(elm);

  /* Gets a value from the localStorage as a result. */
  function get(key){
    result = window.localStorage.getItem(key);
    if(result) {
      return Result.Ok(result);
    } else {
      return Result.Err("Key does not exsists in local storage!");
    }
  }

  /* Sets a value to the localStoraget as a result. */
  function set(key, value){
    try {
      window.localStorage.setItem(key, value);
      return Result.Ok(value);
    } catch (e) {
      return Result.Err("Could not write to local storage!")
    }
  }

  /* Removes a value from the localStorage as a result. */
  function remove(key) {
    try {
      window.localStorage.removeItem(key);
      return Result.Ok(key);
    } catch (e) {
      return Result.Err("Could not delete given key from local storage!");
    }
  }

  /* Interface. */
  return elm.Native.LocalStorage.values = {
    remove: remove,
    set: F2(set),
    get: get
  };
};
