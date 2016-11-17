//download.js v4.1, by dandavis; 2008-2015. [CCBY2] see http://danml.com/download.html for tests/usage
window.download = function(data, strFileName, strMimeType) {
  var self = window, // this script is only for browsers anyway...
    defaultMime = "application/octet-stream", // this default mime also triggers iframe downloads
    mimeType = strMimeType || defaultMime,
    payload = data,
    url = !strFileName && !strMimeType && payload,
    anchor = document.createElement("a"),
    toString = function(a){return String(a);},
    myBlob = (self.Blob || self.MozBlob || self.WebKitBlob || toString),
    fileName = strFileName || "download",
    blob,
    reader;
    myBlob= myBlob.call ? myBlob.bind(self) : Blob ;

  if(String(this)==="true"){ //reverse arguments, allowing download.bind(true, "text/xml", "export.xml") to act as a callback
    payload=[payload, mimeType];
    mimeType=payload[0];
    payload=payload[1];
  }


  if(url && url.length< 2048){ // if no filename and no mime, assume a url was passed as the only argument
    fileName = url.split("/").pop().split("?")[0];
    anchor.href = url; // assign href prop to temp anchor
      if(anchor.href.indexOf(url) !== -1){ // if the browser determines that it's a potentially valid url path:
          var ajax=new XMLHttpRequest();
          ajax.open( "GET", url, true);
          ajax.responseType = 'blob';
          ajax.onload= function(e){
        download(e.target.response, fileName, defaultMime);
      };
          setTimeout(function(){ ajax.send();}, 0); // allows setting custom ajax headers using the return:
        return ajax;
    } // end if valid url?
  } // end if url?


  //go ahead and download dataURLs right away
  if(/^data\:[\w+\-]+\/[\w+\-]+[,;]/.test(payload)){

    if(payload.length > (1024*1024*1.999) && myBlob !== toString ){
      payload=dataUrlToBlob(payload);
      mimeType=payload.type || defaultMime;
    }else{
      return navigator.msSaveBlob ?  // IE10 can't do a[download], only Blobs:
        navigator.msSaveBlob(dataUrlToBlob(payload), fileName) :
        saver(payload) ; // everyone else can save dataURLs un-processed
    }

  }//end if dataURL passed?

  blob = payload instanceof myBlob ?
    payload :
    new myBlob([payload], {type: mimeType}) ;


  function dataUrlToBlob(strUrl) {
    var parts= strUrl.split(/[:;,]/),
    type= parts[1],
    decoder= parts[2] == "base64" ? atob : decodeURIComponent,
    binData= decoder( parts.pop() ),
    mx= binData.length,
    i= 0,
    uiArr= new Uint8Array(mx);

    for(i;i<mx;++i) uiArr[i]= binData.charCodeAt(i);

    return new myBlob([uiArr], {type: type});
   }

  function saver(url, winMode){

    if ('download' in anchor) { //html5 A[download]
      anchor.href = url;
      anchor.setAttribute("download", fileName);
      anchor.className = "download-js-link";
      anchor.innerHTML = "downloading...";
      anchor.style.display = "none";
      document.body.appendChild(anchor);
      setTimeout(function() {
        anchor.click();
        document.body.removeChild(anchor);
        if(winMode===true){setTimeout(function(){ self.URL.revokeObjectURL(anchor.href);}, 250 );}
      }, 66);
      return true;
    }

    // handle non-a[download] safari as best we can:
    if(/(Version)\/(\d+)\.(\d+)(?:\.(\d+))?.*Safari\//.test(navigator.userAgent)) {
      url=url.replace(/^data:([\w\/\-\+]+)/, defaultMime);
      if(!window.open(url)){ // popup blocked, offer direct download:
        if(confirm("Displaying New Document\n\nUse Save As... to download, then click back to return to this page.")){ location.href=url; }
      }
      return true;
    }

    //do iframe dataURL download (old ch+FF):
    var f = document.createElement("iframe");
    document.body.appendChild(f);

    if(!winMode){ // force a mime that will download:
      url="data:"+url.replace(/^data:([\w\/\-\+]+)/, defaultMime);
    }
    f.src=url;
    setTimeout(function(){ document.body.removeChild(f); }, 333);

  }//end saver




  if (navigator.msSaveBlob) { // IE10+ : (has Blob, but not a[download] or URL)
    return navigator.msSaveBlob(blob, fileName);
  }

  if(self.URL){ // simple fast and modern way using Blob and URL:
    saver(self.URL.createObjectURL(blob), true);
  }else{
    // handle non-Blob()+non-URL browsers:
    if(typeof blob === "string" || blob.constructor===toString ){
      try{
        return saver( "data:" +  mimeType   + ";base64,"  +  self.btoa(blob)  );
      }catch(y){
        return saver( "data:" +  mimeType   + "," + encodeURIComponent(blob)  );
      }
    }

    // Blob but not URL support:
    reader=new FileReader();
    reader.onload=function(e){
      saver(this.result);
    };
    reader.readAsDataURL(blob);
  }
  return true;
}

var _gdotdesign$elm_ui$Native_FileManager = function() {
  var isChromeApp = window.chrome && window.chrome.fileSystem


  function createInput(){
    var input = document.createElement('input')

    input.style.width = '1px'
    input.style.height = '1px'
    input.style.position = 'absolute'
    input.style.left = '-1px'
    input.style.top = '-1px'
    input.type = 'file'
    input.callback = null

    document.body.appendChild(input)

    return input;
  }


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

  var Json = _elm_lang$core$Native_Json
  var valueDecoder = Json.decodePrimitive("value")

  function openMultipleDecoder(accept){
    return Json.andThen(function(_){
      var input = createInput()
      input.accept = accept
      input.multiple = false
      input.click()
      var task = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
        input.addEventListener('change', function(){
          var filesArray = Array.prototype.slice.call(input.files)
          var filesObjects = filesArray.map(function(file) { return createFile(file) })
          var files = _elm_lang$core$Native_List.fromArray(filesObjects)
          callback(_elm_lang$core$Native_Scheduler.succeed(files))
        })
      })
      return Json.succeed(task)
    })(valueDecoder)
  }

  function openSingleDecoder(accept){
    return Json.andThen(function(_){
      var input = createInput()
      input.accept = accept
      input.click()
      var task = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
        input.addEventListener('change', function(){
          callback(_elm_lang$core$Native_Scheduler.succeed(createFile(input.files[0])))
        })
      })
      return Json.succeed(task)
    })(valueDecoder)
  }

  return {
    readAsDataURL: readAsDataURL,
    readAsString: readAsString,
    download: F3(downloadFunc),
    openMultipleDecoder: openMultipleDecoder,
    openSingleDecoder: openSingleDecoder,
    identity: function(value){ return value },
    identitiyTag: F2(function(tagger, value){ return tagger(value) }),
    toFormData: toFormData,
  }
}()
