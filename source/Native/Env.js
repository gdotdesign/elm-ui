Elm.Native.Env = {};
Elm.Native.Env.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.Env = elm.Native.Env || {};
  if (elm.Native.Env.values) {return elm.Native.Env.values; }

  /* Gets a value from the ENV. */
  function get(key){
    return window.ENV && window.ENV[key]
  }

  /* Interface. */
  return elm.Native.Env.values = {
    get: get
  };
};
