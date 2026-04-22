const webpack = require('webpack');
const TerserPlugin = require('terser-webpack-plugin');
const {merge} = require('webpack-merge');
const common = require('./common.js');

/**
 * Returns the production webpack config,
 * by merging production specific configuration with the common one.
 *
 */

const prodConfig = () => merge(common, {
  stats: 'minimal',
  optimization: {
    minimizer: [
      new TerserPlugin({
        sourceMap: true,
        terserOptions: {
          /** Zbyt agresywna kompresja niszczyła graf modułów → runtime „e[r] is undefined” w __webpack_require__. */
          ecma: 5,
          compress: {
            inline: 1,
            reduce_funcs: false,
            passes: 1,
            collapse_vars: false,
          },
          mangle: {
            safari10: true,
          },
          output: {
            comments: /@license/i,
          },
        },
        extractComments: false,
        parallel: true,
      }),
    ],
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production'),
    }),
  ],
});

module.exports = prodConfig;
