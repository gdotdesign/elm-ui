define({
  environments: [
    { browserName: 'chrome' },
    { browserName: 'firefox'}
  ],
  tunnel: 'NullTunnel',

  functionalSuites: [
    'specs/Ui/Button.js',
    'specs/Ui/Checkbox.js'
  ],

  reporters: [ 'Pretty' ],

  excludeInstrumentation: /^(?:tests|node_modules|specs)\//
});
