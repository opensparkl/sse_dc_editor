// https://github.com/shelljs/shelljs
require('shelljs/global');
env.NODE_ENV = 'production';

var path = require('path');
var config = require('../config');
var ora = require('ora');
var webpack = require('webpack');
var webpackConfig = require('./webpack.prod-fast.conf');

console.log(
  '  Tip:\n' +
  '  Built files are meant to be served over an HTTP server.\n' +
  '  Opening index.html over file:// won\'t work.\n'
);

//var spinner = ora('building for production...');
console.log('Building for production...');
var assetsPath = path.join(config.build.assetsRoot, config.build.assetsSubDirectory);

console.log('Building to ' + assetsPath + '\n');

rm('-rf', assetsPath);
mkdir('-p', assetsPath);
cp('-R', 'static/*', assetsPath);

//spinner.start();

webpack(webpackConfig, function (err, stats) {
  //spinner.stop();
  if (err) throw err;
  process.stdout.write(stats.toString({
    colors: false,
    modules: false,
    children: false,
    chunks: false,
    chunkModules: false
  }) + '\n')
});
