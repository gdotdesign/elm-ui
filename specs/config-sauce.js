define(['intern/dojo/node!dotenv'], function(dotenv){
  var build = "build-" + (Date.now())
  dotenv.load();
  return {
    environments: [
      { build: build, browserName: 'chrome' },
      { build: build, browserName: 'firefox'},
      { build: build, browserName: 'internet explorer', version: ['10', '11'], platform: ['Windows 7'] },
      { build: build, browserName: 'safari', platform: [ 'OS X 10.11', 'OS X 10.10', 'OS X 10.9' ]}
    ],
    tunnel: 'SauceLabsTunnel',
    tunnelOptions: {
      username: process.env.SAUCE_USERNAME,
      accessKey: process.env.SAUCE_ACCESS_KEY
    },
    functionalSuites: [
      'specs/Ui/Button.js',
      'specs/Ui/Checkbox.js'
    ],

    reporters: [ 'Pretty' ],

    excludeInstrumentation: /^(?:tests|node_modules|specs)\//
  }
});
