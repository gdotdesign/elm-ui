var exec = require('child_process').exec;
var fs = require('fs')

var script =
`(function(){
  if (typeof Elm === "undefined") { throw "elm-io config error: Elm is not defined. Make sure you call elm-io with a real Elm output file"}
  if (typeof Elm.Main === "undefined" ) { throw "Elm.Main is not defined, make sure your module is named Main." };
  var worker = Elm.worker(Elm.Main);
})();`

var cmd = `elm-make tests/Runner.elm --output test.js`;
exec(cmd, function(error, stdout, stderr) {
  if (stderr) {
    console.error(stderr)
  } else {
    var contents = fs.readFileSync('test.js', 'utf-8')
    fs.writeFileSync('test.js', contents + script);
    exec(`node test.js`, function(error, stdout, stderr) {
      console.log(stdout)
      fs.unlink('test.js')
    })
  }
});
