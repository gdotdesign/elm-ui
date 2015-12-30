define(['specs/specs'],function(specs) {
  return {
    environments: [{
      browserName: 'chrome'
    }, {
      browserName: 'firefox'
    }],
    tunnel: 'NullTunnel',
    functionalSuites: specs,
    reporters: ['Pretty'],
    excludeInstrumentation: /^(?:tests|node_modules|specs)\//
  }
});
