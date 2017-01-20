var _gdotdesign$elm_ui$Native_Uid = function() {
  function s(n) {
    return h((Math.random() * (1<<(n<<2)))^Date.now()).slice(-n)
  }

  function h(n) {
    return (n|0).toString(16)
  }

  function uid(){
    return [
      s(4) + s(4), s(4), '4' + s(3),
      h(8|(Math.random()*4)) + s(3),
      Date.now().toString(16).slice(-10) + s(2)
    ].join('-')
  }

  function getTags(memo, node) {
    if(node.type === 'text') { return memo }
    if(node.type === 'thunk') { node = node.thunk() }
    if(!node) { return memo}
    memo[node.tag] = true
    node.children.reduce(getTags, memo)
    return memo
  }

  /* Interface */
  return {
    getTags: function(a) {
      return _elm_lang$core$Native_List.fromArray(Object.keys(getTags({},a)))
    },
    uid: uid
  }
}()
