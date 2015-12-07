Elm.Native.Uid = {};
Elm.Native.Uid.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.Uid = elm.Native.Uid || {};
  if (elm.Native.Uid.values) {
    return elm.Native.Uid.values;
  }

  function s(n) { return h((Math.random() * (1<<(n<<2)))^Date.now()).slice(-n); }
  function h(n) { return (n|0).toString(16); }

  function uid(){
    return  [
      s(4) + s(4), s(4),
      '4' + s(3),                    // UUID version 4
      h(8|(Math.random()*4)) + s(3), // {8|9|A|B}xxx
      // s(4) + s(4) + s(4),
      Date.now().toString(16).slice(-10) + s(2) // Use timestamp to avoid collisions
    ].join('-');
  }

  return Elm.Native.Uid.values = {
    uid: uid
  };
};
