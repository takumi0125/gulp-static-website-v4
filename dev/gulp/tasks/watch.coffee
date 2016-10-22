#############
### watch ###
#############

connectSSI = require 'connect-ssi'

module.exports = (gulp, gulpPlugins, config, utils)->
  gulp.task 'watch', config.watchifyTaskNames, ->
    # config.pugData更新時
    gulp.watch config.pugData, [ 'pugAll' ]

    gulp.watch utils.createSrcArr('html'),     [ 'copyHtml' ]
    gulp.watch utils.createSrcArr('css'),      [ 'copyCss' ]
    gulp.watch utils.createSrcArr('js'),       [ 'copyJs' ]
    gulp.watch utils.createSrcArr('json'),     [ 'copyJson' ]
    gulp.watch utils.createSrcArr('img'),      [ 'copyImg' ]
    gulp.watch utils.createSrcArr('others'),   [ 'copyOthers' ]
    gulp.watch utils.createSrcArr('pug'),      [ 'pug' ]
    gulp.watch utils.createSrcArr('sass'),     [ 'sass' ]
    gulp.watch utils.createSrcArr('coffee'),   [ 'coffee' ]

    # インクルードファイル(アンスコから始まるファイル)更新時はすべてをコンパイル
    gulp.watch config.filePath.pugInclude,      [ 'pugAll' ]
    gulp.watch config.filePath.sassInclude,     [ 'sassAll' ]
    gulp.watch config.filePath.coffeeInclude,   [ 'coffeeAll' ]

    for task in config.optionsWatchTasks then task()

    gulp.src config.publishDir
    .pipe gulpPlugins.webserver
      livereload: true
      port: 50000
      open: config.serverDefaultPath
      directoryListing: true
      host: '0.0.0.0'
      middleware:
        connectSSI
          baseDir: config.publishDir
          ext: '.html'
    .pipe gulpPlugins.notify "[watcher]: start local server. http://localhost:50000#{config.serverDefaultPath}"
