#############
### utils ###
#############

browserify    = require 'browserify'
buffer        = require 'vinyl-buffer'
pngquant      = require 'imagemin-pngquant'
mergeStream   = require 'merge-stream'
source        = require 'vinyl-source-stream'
watchify      = require 'watchify'
webpackStream = require 'webpack-stream'
webpack       = require 'webpack'


module.exports = (gulp, gulpPlugins, config)->
  utils =
    #
    # spritesmith のタスクを生成
    #
    # @param {String}  taskName      タスクを識別するための名前 すべてのタスク名と異なるものにする
    # @param {String}  imgDir        ソース画像ディレクトリへのパス (ドキュメントルートからの相対パス)
    # @param {String}  cssDir        ソースCSSディレクトリへのパス (ドキュメントルートからの相対パス)
    # @param {String}  outputImgName 指定しなければ#{taskName}.pngになる
    # @param {String}  outputImgPath CSSに記述される画像パス (相対パスの際に指定する)
    # @param {Boolean} compressImg   画像を圧縮するかどうか
    #
    # #{config.srcDir}#{imgDir}/_#{taskName}/
    # 以下にソース画像を格納しておくと
    # #{config.srcDir}#{cssDir}/_#{taskName}.scss と
    # #{config.srcDir}#{imgDir}/#{taskName}.png が生成される
    # かつ watch タスクの監視も追加
    #
    createSpritesTask: (taskName, imgDir, cssDir, outputImgName = '', outputImgPath = '', compressImg = false) ->
      config.spritesTaskNames.push taskName

      srcImgFiles = "#{config.srcDir}/#{imgDir}/#{config.excrusionPrefix}#{taskName}/*"
      config.filePath.img.push "!#{srcImgFiles}"

      gulp.task taskName, ->

        spriteObj =
          imgName: "#{outputImgName or taskName}.png"
          cssName: "#{config.excrusionPrefix}#{taskName}.scss"
          algorithm: 'binary-tree'
          padding: 2
          cssOpts:
            variableNameTransforms: ['camelize']

        if outputImgPath then spriteObj.imgPath = outputImgPath

        spriteData = gulp.src srcImgFiles
        .pipe gulpPlugins.plumber errorHandler: utils.errorHandler taskName
        .pipe gulpPlugins.spritesmith spriteObj

        imgStream = spriteData.img

        # 画像圧縮
        if compressImg
          imgStream = imgStream
          .pipe buffer()
          .pipe gulpPlugins.imagemin {
            use: [
              pngquant
                quality: '60-80'
                speed: 4
            ]
          }

        imgStream
        .pipe gulp.dest "#{config.srcDir}/#{imgDir}"
        .pipe gulp.dest "#{config.publishDir}/#{imgDir}"

        cssStream = spriteData.css.pipe gulp.dest "#{config.srcDir}/#{cssDir}"

        mergeStream imgStream, cssStream

      config.optionsWatchTasks.unshift -> gulp.watch srcImgFiles, [ taskName ]


    #
    # coffee scriptでconcatする場合のタスクを生成
    #
    # @param {String}       taskName        タスクを識別するための名前 すべてのタスク名と異なるものにする
    # @param {Array|String} src             ソースパス node-globのシンタックスで指定
    # @param {String}       outputDir       最終的に出力されるjsが格納されるディレクトリ
    # @param {String}       outputFileName  最終的に出力されるjsファイル名(拡張子なし)
    # @param {Boolean}      compress        圧縮するかどうか
    #
    createCoffeeExtractTask: (taskName, src, outputDir, outputFileName, compress = true) ->
      config.jsConcatTaskNames.push taskName
      if src instanceof String then src = [ src ]
      for srcPath in src then config.filePath.coffeeInclude.push "!#{srcPath}"

      gulp.task taskName, ->
        stream = gulp.src src
        .pipe gulpPlugins.plumber errorHandler: utils.errorHandler taskName
        .pipe gulpPlugins.coffeelint {
          camel_case_classes: level: 'ignore'
          max_line_length: level: 'ignore'
          no_unnecessary_fat_arrows: level: 'ignore'
        }
        .pipe gulpPlugins.coffeelint.reporter()

        stream = utils.sourcemap stream, (stream)->
          stream = stream
          .pipe gulpPlugins.concat outputFileName
          .pipe gulpPlugins.coffee()
          return utils.compressJs stream

        stream
        .pipe gulp.dest outputDir
        .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan("[#{taskName}]")

      config.optionsWatchTasks.push -> gulp.watch src, [ taskName ]


    #
    # browserifyのタスクを生成 (coffeescript, babel[es2015]使用)
    #
    # @param {String}       taskName        タスクを識別するための名前 すべてのタスク名と異なるものにする
    # @param {Array|String} entries         browserifyのentriesオプションに渡す node-globのシンタックスで指定
    # @param {String}       outputDir       最終的に出力されるjsが格納されるディレクトリ
    # @param {String}       outputFileName  最終的に出力されるjsファイル名(拡張子なし)
    # @param {String}       compress        圧縮するかどうか
    #
    # entries以外のソースファイルを指定する理由は、coffeeInclude標準のwatchの監視の対象外にするためです。
    #
    createBrowserifyTask: (taskName, entries, outputDir, outputFileName, compress = true) ->
      config.jsConcatTaskNames.push taskName

      if entries instanceof String then entries = [ entries ]
      for entryPath in entries then config.filePath.coffeeInclude.push "!#{entryPath}"

      bundle = (b)->
        stream = b.bundle()
        # .pipe gulpPlugins.plumber errorHandler: utils.errorHandler taskName
        .on 'error', ->
          # can't handle error by plumber
          args = Array.prototype.slice.call arguments

          gulpPlugins.notify.onError
            title: "#{taskName} Error"
            message: '<%= error.message %>'
          .apply @, args

          @emit 'end'
        .pipe source "#{outputFileName}.js"
        .pipe buffer()

        stream = utils.sourcemap(
          stream
          (stream)-> return utils.compressJs stream
          { loadMaps: true }
        )

        stream
        .pipe gulp.dest outputDir
        .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan("[#{taskName}]")


      browserifyTask = (watch = false)->
        b = browserify
          entries: entries
          extensions: [ '.coffee' ]
          debug: true
        .transform 'babelify', { presets: [ 'es2015' ] }
        .transform 'coffeeify'
        .transform 'debowerify'

        if watch
          b.plugin watchify
          b.on 'update', -> bundle(b)

        bundle b

      watchifyTaskName = "#{taskName}Watchify"

      gulp.task taskName, -> browserifyTask(false)
      gulp.task watchifyTaskName, -> browserifyTask(true)

      config.watchifyTaskNames.push watchifyTaskName


    #
    # webpackのタスクを生成 (coffeescript, babel[es2015]使用)
    #
    # @param {String}       taskName        タスクを識別するための名前 すべてのタスク名と異なるものにする
    # @param {Array|String} entries         browserifyのentriesオプションに渡す node-globのシンタックスで指定
    # @param {Array|String} src             entriesを除いた全ソースファイル (watchタスクで監視するため) node-globのシンタックスで指定
    # @param {String}       outputDir       最終的に出力されるjsが格納されるディレクトリ
    # @param {String}       outputFileName  最終的に出力されるjsファイル名(拡張子なし)
    # @param {Boolean}      compress        圧縮するかどうか
    #
    # entries以外のソースファイルを指定する理由は、coffeeInclude標準のwatchの監視の対象外にするためです。
    #
    createWebpackJsTask: (taskName, entries, src, outputDir, outputFileName, compress = true) ->
      config.jsConcatTaskNames.push taskName

      if entries instanceof String then entries = [ entries ]
      for entryPath in entries then config.filePath.coffeeInclude.push "!#{entryPath}"

      if src instanceof String then src = [ src ]
      for srcPath in src then config.filePath.coffeeInclude.push "!#{srcPath}"

      webpackConfig =
        entry: entries
        output:
          path: outputDir
          comments: false
          filename: "#{outputFileName}.js"
        module:
          loaders: [
            { test: /\.coffee$/, loader: 'coffee-loader' }
            { test: /\.js$/, loader: 'babel-loader', query: presets: [ 'es2015' ] }
          ]
        plugins: [
          new webpack.ResolverPlugin(
            new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin("bower.json", ["main"])
          ),
        ]

        resolve:
          extensions: ['', '.js', '.json', '.coffee']

      if config.sourcemap
        webpackConfig.devtool = 'source-map'

      if config.compress.js
        webpackConfig.plugins.push new webpack.optimize.UglifyJsPlugin()


      gulp.task taskName, ->
        stream = gulp.src entries
        .pipe webpackStream webpackConfig

        jsFilter = gulpPlugins.filter ['*.js', '!*.map'], { restore: true }
        stream = stream.pipe jsFilter
        stream = utils.compressJs stream
        .pipe jsFilter.restore

        stream.pipe gulp.dest outputDir

      config.optionsWatchTasks.push -> gulp.watch src, [ taskName ]


    #
    # javascriptのconcatタスクを生成
    #
    # @param {String}       taskName        タスクを識別するための名前 すべてのタスク名と異なるものにする
    # @param {Array|String} src             ソースパス node-globのシンタックスで指定
    # @param {String}       outputDir       最終的に出力されるjsが格納されるディレクトリ
    # @param {String}       outputFileName  最終的に出力されるjsファイル名(拡張子なし)
    #
    createJsConcatTask: (taskName, src, outputDir, outputFileName = 'lib')->
      config.jsConcatTaskNames.push taskName

      gulp.task taskName, ->
        stream = gulp.src src
        .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'concat'

        stream = utils.sourcemap stream, (stream)->
          return stream
          .pipe gulpPlugins.concat "#{outputFileName}.js", { newLine: ';' }
          .pipe gulpPlugins.uglify preserveComments: 'some'

        stream
        .pipe gulp.dest outputDir
        .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan("[#{taskName}]")

      config.optionsWatchTasks.push -> gulp.watch src, [ taskName ]


    #
    # エラー出力
    #
    errorHandler: (name)-> gulpPlugins.notify.onError title: "#{name} Error", message: '<%= error.message %>'


    #
    # タスク対象のファイル、ディレクトリの配列を生成
    #
    createSrcArr: (name)->
      [].concat config.filePath[name], [
        "!#{config.srcDir}/**/#{config.excrusionPrefix}*"
        "!#{config.srcDir}/**/#{config.excrusionPrefix}*/"
        "!#{config.srcDir}/**/#{config.excrusionPrefix}*/**"
      ]


    #
    # gulpのログの形式でconsole.log
    #
    msg: (msg)->
      d = new Date()
      console.log "[#{gulpPlugins.util.colors.gray(d.getHours() + ':' + d.getMinutes() + ':' + d.getSeconds())}] #{msg}"


    #
    # sourcemap
    #
    sourcemap: (stream, callback, initOpt = {})->
      if config.sourcemap
        stream = stream.pipe gulpPlugins.sourcemaps.init(initOpt)
        stream = callback stream
        return stream.pipe gulpPlugins.sourcemaps.write('.')
      else
        return callback stream


    #
    # compressJs
    #
    compressJs: (stream, sourcemap = false)->
      if config.compress.js
        if sourcemap
          return utils.sourcemap stream, (stream)->
            return stream.pipe gulpPlugins.uglify preserveComments: 'some'
        else
          return stream.pipe gulpPlugins.uglify preserveComments: 'some'
      else
        return stream


    #
    # compressCss
    #
    compressCss: (stream, sourcemap = false)->
      if config.compress.css
        if sourcemap
          return utils.sourcemap stream, (stream)->
            return stream.pipe gulpPlugins.cssmin()
        else
          return stream.pipe gulpPlugins.cssmin()
      else
        return stream
