define({
  environments: [
    { browserName: 'chrome' },
    { browserName: 'firefox'}
  ],
  tunnel: 'NullTunnel',

  functionalSuites: [ 'specs/Ui/Button.js' ],

  //reporters: [ 'Pretty' ],

  excludeInstrumentation: /./
});
