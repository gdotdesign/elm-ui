//download.js v4.1, by dandavis; 2008-2015. [CCBY2] see http://danml.com/download.html for tests/usage
(function(q,k){"function"==typeof define&&define.amd?define([],k):"object"==typeof exports?module.exports=k():q.download=k()})(this,function(){return function k(b,c,e){function r(n){var a=n.split(/[:;,]/);n=a[1];var a=("base64"==a[2]?atob:decodeURIComponent)(a.pop()),b=a.length,d=0,c=new Uint8Array(b);for(d;d<b;++d)c[d]=a.charCodeAt(d);return new g([c],{type:n})}function l(a,b){if("download"in d)return d.href=a,d.setAttribute("download",m),d.className="download-js-link",d.innerHTML="downloading...",h.body.appendChild(d),setTimeout(function(){d.click(),h.body.removeChild(d),!0===b&&setTimeout(function(){f.URL.revokeObjectURL(d.href)},250)},66),!0;if("undefined"!=typeof safari)return a="data:"+a.replace(/^data:([\w\/\-\+]+)/,"application/octet-stream"),!window.open(a)&&confirm("Displaying New Document\n\nUse Save As... to download, then click back to return to this page.")&&(location.href=a),!0;var c=h.createElement("iframe");h.body.appendChild(c),b||(a="data:"+a.replace(/^data:([\w\/\-\+]+)/,"application/octet-stream")),c.src=a,setTimeout(function(){h.body.removeChild(c)},333)}var f=window,a=e||"application/octet-stream";e=!c&&!e&&b;var h=document,d=h.createElement("a"),p=function(a){return String(a)},g=f.Blob||f.MozBlob||f.WebKitBlob||p,m=c||"download",g=g.call?g.bind(f):Blob;"true"===String(this)&&(b=[b,a],a=b[0],b=b[1]);if(e&&2048>e.length&&(m=e.split("/").pop().split("?")[0],d.href=e,-1!==d.href.indexOf(e)))return a=new XMLHttpRequest,a.open("GET",e,!0),a.responseType="blob",a.onload=function(a){k(a.target.response,m,"application/octet-stream")},a.send(),a;if(/^data\:[\w+\-]+\/[\w+\-]+[,;]/.test(b))return navigator.msSaveBlob?navigator.msSaveBlob(r(b),m):l(b);c=b instanceof g?b:new g([b],{type:a});if(navigator.msSaveBlob)return navigator.msSaveBlob(c,m);if(f.URL)l(f.URL.createObjectURL(c),!0);else{if("string"==typeof c||c.constructor===p)try{return l("data:"+a+";base64,"+f.btoa(c))}catch(n){return l("data:"+a+","+encodeURIComponent(c))}a=new FileReader,a.onload=function(a){l(this.result)},a.readAsDataURL(c)}return!0}});

var _gdotdesign$elm_ui$Native_FileManager = function() {
  var isChromeApp = window.chrome && window.chrome.fileSystem

  var input = document.createElement('input')

  input.style.width = '1px'
  input.style.height = '1px'
  input.style.position = 'absolute'
  input.style.left = '-1px'
  input.style.top = '-1px'
  input.type = 'file'
  input.callback = null

  document.body.appendChild(input)

  function createFile(file) {
    return {
      name: file.name,
      size: file.size,
      mimeType: file.type,
      data: file
    }
  }

  function reader(callback) {
    var reader = new FileReader();
    reader.addEventListener('load', function(event){
      callback(_elm_lang$core$Native_Scheduler.succeed(event.target.result))
    })
    return reader
  }

  function readAsString(file) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      reader(callback).readAsText(file.data)
    })
  }

  function readAsDataURL(file) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      reader(callback).readAsDataURL(file.data)
    })
  }

  function toFormData(file) {
    return file.data
  }

  function openMultiple(accept){
    input.multiple = true
    return open(accept, function(callback){
      var filesArray = Array.prototype.slice.call(input.files)
      var filesObjects = filesArray.map(function(file) { return createFile(file) })
      var files = _elm_lang$core$Native_List.fromArray(filesObjects)
      callback(_elm_lang$core$Native_Scheduler.succeed(files))
    })
  }

  function openSingle(accept){
    input.multiple = false

    return open(accept, function(callback){
      var file = createFile(input.files[0])
      callback(_elm_lang$core$Native_Scheduler.succeed(file))
    })
  }

  function open(accept, mainCallback){
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
      input.accept = accept
      input.value = ''
      // Make sure that previous callbacks are not called
      input.removeEventListener('change', input.callback)
      input.callback = function(){ mainCallback(callback) }
      input.addEventListener('change', input.callback)
      input.click()
    });
  }

  function downloadFunc(name,mimeType,data){
    if(isChromeApp){
      return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
        chrome.fileSystem.chooseEntry({type: 'saveFile',
                                       suggestedName: name}, function(fileEntry){
          blob = new Blob([data], {type: "text/plain"})
          fileEntry.createWriter(function(writer) {
            writer.onwriteend = function() {
              if (writer.length === 0) {
                writer.write(blob)
              } else {
                callback(_elm_lang$core$Native_Scheduler.succeed(""))
              }
            }
            writer.truncate(0)
          })
        })
      })
    } else {
      download(data,name,mimeType)
      return _elm_lang$core$Native_Scheduler.succeed("")
    }
  }

  return {
    readAsDataURL: readAsDataURL,
    readAsString: readAsString,
    download: F3(downloadFunc),
    openMultiple: openMultiple,
    openSingle: openSingle,
    toFormData: toFormData,
  }
}()
