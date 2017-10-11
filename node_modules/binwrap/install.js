var fs = require("fs");
var path = require("path");
var binstall = require(path.join(__dirname, "binstall"));

module.exports = function install(config, os, arch) {
  if (!fs.existsSync("bin")) {
    fs.mkdirSync("bin");
  }

  var binExt = "";
  if (os == "win32") {
    binExt = ".exe";
  }

  config.binaries.forEach(function(bin) {
    var binPath = path.join("bin", bin);
    fs.writeFileSync(
      binPath,
      "#!/usr/bin/env node\n" +
        'var path = require("path");\n' +
        'var spawn = require("child_process").spawn;\n' +
        'spawn(path.join(__dirname, "..", "unpacked_bin", "' +
        (bin + binExt) +
        "\"), process.argv.slice(2), {stdio: 'inherit'}).on('exit', process.exit);"
    );
    fs.chmodSync(binPath, "755");
  });

  var buildId = os + "-" + arch;
  var url = config.urls[buildId];
  if (!url) {
    throw new Error("No binaries are available for your platform: " + buildId);
  }
  return binstall(url, "unpacked_bin").then(function() {
    config.binaries.forEach(function(bin) {
      fs.chmodSync(path.join("unpacked_bin", bin + binExt), "755");
    });
    // verifyAllBinsExist(packageInfo.bin);
  });
};

// function verifyAllBinsExist(binInfo) {
//   Object.keys(binInfo).forEach(function(name) {
//     var bin = binInfo[name];
//     if (!fs.existsSync(bin)) {
//       throw new Error(
//         "bin listed in package.json does not exist: " +
//           bin +
//           "\n\nTODO: Maybe you forgot to include it in ..."
//       );
//     }
//   });
// }
