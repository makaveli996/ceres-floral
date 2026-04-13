const path = require('path');
const { execSync } = require('child_process');
const TerserPlugin = require('terser-webpack-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

// Repo root: run webpack from project root (ceres-floral/). Source in _dev/, output in prestashop/themes/ceres_floral/assets/
const rootDir = path.resolve(__dirname);
const themeDir = path.join(rootDir, 'prestashop', 'themes', 'ceres_floral');
const themeAssetsDir = path.join(themeDir, 'assets');
const devDir = path.join(rootDir, '_dev');

// Custom plugin to clear PrestaShop cache after build
class PrestaShopCacheClearPlugin {
  constructor(options = {}) {
    this.options = {
      enabled: options.enabled !== false, // Enabled by default
      clearOnWatch: options.clearOnWatch !== false, // Clear in watch mode by default
      watchTemplates: options.watchTemplates !== false, // Watch .tpl files by default
      ...options,
    };
    this.watchers = [];
    this.clearCacheDebounce = null;
    this._lastClear = null; // { path, mtimeMs } — only clear when mtime changed (real save)
    this._lastClearTime = 0;
    this._clearCooldownMs = 10000; // at most one clear per 10s
    this._clearInProgress = false; // only one clear at a time
  }

  apply(compiler) {
    if (!this.options.enabled) {
      return;
    }

    // Done hook: only clear cache when explicitly requested (clearOnWatch: true), not on every SCSS/JS rebuild
    compiler.hooks.done.tap('PrestaShopCacheClearPlugin', (stats) => {
      if (!this.options.enabled) return;

      const isWatchMode = compiler.watching !== null;
      const shouldClear = isWatchMode ? this.options.clearOnWatch : false;
      if (!shouldClear) return;

      setImmediate(() => this.clearCache());
    });

    // Watch for template file changes in watch mode
    compiler.hooks.watchRun.tapAsync('PrestaShopCacheClearPlugin', (compilation, callback) => {
      if (this.options.watchTemplates && this.watchers.length === 0) {
        this.setupTemplateWatcher(compiler);
      }
      callback();
    });

    // Also set up watcher when compiler starts (for initial watch mode)
    if (compiler.options.watch) {
      setImmediate(() => {
        if (this.options.watchTemplates && this.watchers.length === 0) {
          this.setupTemplateWatcher(compiler);
        }
      });
    }

    // Clean up watchers when done
    compiler.hooks.done.tap('PrestaShopCacheClearPlugin', () => {
      // Watchers will be cleaned up when webpack stops
    });
  }

  setupTemplateWatcher(compiler) {
    const fs = require('fs');
    const prestashopRoot = path.join(rootDir, 'prestashop');

    const watchPaths = [
      path.join(themeDir, 'templates'),
      path.join(themeDir, 'modules'),
      path.join(prestashopRoot, 'modules'), // e.g. tc_stickybar/views/templates/hook/*.tpl
    ];

    const watchDirectory = (dir) => {
      if (!fs.existsSync(dir)) {
        return;
      }

      try {
        // Watch the directory itself
        const watcher = fs.watch(dir, (eventType, filename) => {
          if (filename) {
            const fullPath = path.join(dir, filename);
            
            // Check if it's a .tpl file or a directory
            fs.stat(fullPath, (err, stats) => {
              if (err) return;
              if (stats.isDirectory()) {
                watchDirectory(fullPath);
                return;
              }
              // Only react to .tpl files
              if (!stats.isFile() || !filename || !filename.toLowerCase().endsWith('.tpl')) return;

              if (this.clearCacheDebounce) clearTimeout(this.clearCacheDebounce);
              this.clearCacheDebounce = setTimeout(() => {
                if (this._clearInProgress) return;
                if (Date.now() - this._lastClearTime < this._clearCooldownMs) return;

                fs.stat(fullPath, (err2, stats2) => {
                  if (err2 || !stats2 || !stats2.isFile()) return;
                  const currentMtime = stats2.mtimeMs;
                  if (this._lastClear && this._lastClear.path === fullPath && this._lastClear.mtimeMs === currentMtime) {
                    return; // atime-only (container read), not a new save
                  }
                  this._lastClear = { path: fullPath, mtimeMs: currentMtime };
                  console.log(`\n📝 Template changed: ${path.relative(prestashopRoot, fullPath)} → clearing cache`);
                  this.clearCache();
                });
              }, 500); // debounce: wait for rapid saves to settle
            });
          }
        });
        
        this.watchers.push(watcher);

        // Also watch subdirectories
        try {
          const entries = fs.readdirSync(dir, { withFileTypes: true });
          entries.forEach(entry => {
            if (entry.isDirectory()) {
              watchDirectory(path.join(dir, entry.name));
            }
          });
        } catch (err) {
          // Ignore readdir errors
        }
      } catch (error) {
        // Some systems don't support watching
        console.log(`⚠️  Could not watch ${dir}: ${error.message}`);
      }
    };

    watchPaths.forEach(watchPath => {
      watchDirectory(watchPath);
    });

    console.log('👀 Watching template files (.tpl) for changes...');
  }

  clearCache() {
    if (this._clearInProgress) return;
    this._clearInProgress = true;
    this._lastClearTime = Date.now();

    const fs = require('fs');
    const cacheScript = path.join(rootDir, 'clear-cache.sh');
    const reloadSentinel = path.join(themeAssetsDir, '.reload');

    const done = () => {
      this._clearInProgress = false;
    };

    console.log('\n🧹 Clearing PrestaShop cache (fast)...');

    // 1) Prefer make cache-clear-fast (file wipe in container, no PHP) — light and no sudo
    try {
      execSync('make cache-clear-fast', { cwd: rootDir, stdio: 'pipe', encoding: 'utf8' });
      console.log('✅ Cache cleared (fast).\n');
      try { fs.writeFileSync(reloadSentinel, String(Date.now()), 'utf8'); } catch (_) {}
      done();
      return;
    } catch (_) {}

    // 2) clear-cache.sh (tries cache-clear-fast then cache-clear)
    try {
      if (fs.existsSync(cacheScript)) {
        execSync(`bash "${cacheScript}"`, { cwd: rootDir, stdio: 'inherit', encoding: 'utf8' });
        console.log('✅ Cache cleared.\n');
        try { fs.writeFileSync(reloadSentinel, String(Date.now()), 'utf8'); } catch (_) {}
        done();
        return;
      }
    } catch (_) {}

    // 3) Full Symfony clear (heavy)
    try {
      execSync('make cache-clear', { cwd: rootDir, stdio: 'inherit', encoding: 'utf8' });
      console.log('✅ Cache cleared (make cache-clear).\n');
      try { fs.writeFileSync(reloadSentinel, String(Date.now()), 'utf8'); } catch (_) {}
      done();
      return;
    } catch (_) {}

    // 4) Host fallback (may fail if cache owned by www-data)
    try {
      const prestashopRoot = path.join(rootDir, 'prestashop');
      const cacheDir = path.join(prestashopRoot, 'var', 'cache');
      const themesConfigDir = path.join(prestashopRoot, 'config', 'themes');
      if (fs.existsSync(cacheDir)) {
        execSync(`find "${cacheDir}" -mindepth 1 -maxdepth 1 ! -name "." -exec rm -rf {} + 2>/dev/null || true`, { cwd: rootDir, stdio: 'pipe' });
      }
      if (fs.existsSync(themesConfigDir)) {
        execSync(`find "${themesConfigDir}" -name "*.json" -type f -delete 2>/dev/null || true`, { cwd: rootDir, stdio: 'pipe' });
      }
      console.log('✅ Cache cleared (host fallback).\n');
      try { fs.writeFileSync(reloadSentinel, String(Date.now()), 'utf8'); } catch (_) {}
    } catch (e) {
      console.log(`⚠️  Cache clear error: ${e.message}`);
      console.log('   Run manually: make cache-clear-fast or make cache-clear\n');
    }
    done();
  }
}

module.exports = (env, argv) => {
  const isProduction = argv.mode === 'production';
  const outputPath = path.join(themeAssetsDir, 'js');
  const entryPath = path.join(devDir, 'js', 'theme.js');

  return {
    context: rootDir,
    resolve: {
      alias: {
        _dev: devDir,
      },
      // So source (Classic) can use bare 'update-sources' and resolve to ./update-sources.js
      preferRelative: true,
    },
    // PrestaShop provides these at runtime; source (Classic) theme expects them as externals
    externals: {
      prestashop: 'prestashop',
      jquery: 'jQuery',
      $: 'jQuery',
    },
    entry: {
      theme: entryPath,
    },
    output: {
      path: outputPath,
      // Core always enqueues "theme.js" (id: theme-main); use same name so the file is found
      filename: '[name].js',
      clean: false, // Don't clean, we have other files here
      publicPath: '../css/', // Set publicPath for assets referenced in CSS
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-env'],
            },
          },
        },
        {
          test: /\.scss$/,
          use: [
            MiniCssExtractPlugin.loader,
            {
              loader: 'css-loader',
              options: {
                sourceMap: !isProduction,
                // Resolve fonts and node_modules assets; leave theme asset paths as-is (served at runtime)
                url: {
                  filter: (url) => {
                    if (url.startsWith('../img/') || url.startsWith('../../assets/img/')) return false;
                    return true;
                  },
                },
              },
            },
            {
              loader: 'postcss-loader',
              options: {
                postcssOptions: {
                  plugins: [
                    require('autoprefixer'),
                  ],
                },
                sourceMap: !isProduction,
              },
            },
            {
              loader: 'sass-loader',
              options: {
                sourceMap: !isProduction,
                sassOptions: {
                  outputStyle: isProduction ? 'compressed' : 'expanded',
                },
              },
            },
          ],
        },
        {
          // Handle font files referenced in CSS
          test: /\.(woff2?|eot|ttf|otf)$/i,
          type: 'asset/resource',
          generator: {
            filename: '../css/[hash][ext][query]',
          },
        },
        {
          // Handle image files referenced in CSS
          test: /\.(jpg|jpeg|png|gif|svg|webp)$/i,
          type: 'asset/resource',
          generator: {
            filename: '../img/[name][ext][query]',
          },
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: '../css/[name].css',
        chunkFilename: '../css/[name].css',
      }),
      // Clear cache on .tpl edit only (mtime check prevents loop from container atime updates). Touch .reload → BrowserSync reloads.
      new PrestaShopCacheClearPlugin({
        enabled: !isProduction,
        clearOnWatch: false,
        watchTemplates: true,
      }),
    ],
    optimization: {
      minimize: isProduction,
      minimizer: [
        new TerserPlugin({
          terserOptions: {
            compress: {
              drop_console: isProduction,
            },
          },
        }),
        new CssMinimizerPlugin(),
      ],
    },
    devtool: isProduction ? false : 'source-map',
    stats: {
      colors: true,
      modules: false,
      children: false,
      chunks: false,
      chunkModules: false,
    },
  };
};
