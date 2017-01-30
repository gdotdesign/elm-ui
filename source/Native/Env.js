var _gdotdesign$elm_ui$Native_Env = function() {
  /* Gets a value from the ENV. */
  function get(key){
    return window.ENV && window.ENV[key]
  }

  /* Interface. */
  return {
    get: get
  }
}()
