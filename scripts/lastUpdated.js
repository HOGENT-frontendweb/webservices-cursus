(function () {
  function lastUpdatedPlugin(hook) {
    hook.beforeEach(function(markdown) {
      return (
        markdown +
        '\n----\n' +
        '_Laatste aanpassing op {docsify-updated}_'
      );
    });
  }

  window.$docsify = window.$docsify || {};
  window.$docsify.plugins = [].concat(lastUpdatedPlugin, $docsify.plugins);
})();