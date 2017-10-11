var request = require("request-promise");

module.exports = function test(config) {
  var errors = 0;
  var chain = Object.keys(config.urls).reduce(
    function(p, buildId) {
      var url = config.urls[buildId];
      return p.then(function() {
        return request({
          method: "GET",
          uri: url,
          resolveWithFullResponse: true
        })
          .then(function(response) {
            if (response.statusCode != 200) {
              throw new Error("Status code " + response.statusCode);
            }
            console.log("OKAY: " + url);
          })
          .catch(function(err) {
            console.error("  - Failed to fetch " + url + " " + err.message);
            errors += 1;
          });
      });
    },
    Promise.resolve()
  );
  return chain.then(function() {
    if (errors > 0) {
      var output = "There were errors when validating your published packages\n";
      throw new Error(output);
    }
  });
};
