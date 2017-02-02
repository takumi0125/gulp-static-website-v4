############
### sass ###
############

module.exports = (gulp, gulpPlugins, config, utils)->
  # sass
  gulp.task 'sass', ->
    stream = gulp.src utils.createSrcArr 'sass'
    .pipe gulpPlugins.changed config.publishDir, { extension: '.css' }
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'sass'

    stream = utils.sourcemap stream, (stream)->
      return stream.pipe gulpPlugins.sass outputStyle: 'expanded'
      .pipe gulpPlugins.postcss([
        require('autoprefixer')({ browsers: config.autoprefixerOpt })
        require('cssnano')({ autoprefixer: false })
      ])

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[sass]:')


  # sassAll
  gulp.task 'sassAll', ->
    stream = gulp.src utils.createSrcArr 'sass'
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'sass'

    stream = utils.sourcemap stream, (stream)->
      return stream.pipe gulpPlugins.sass outputStyle: 'expanded'
      .pipe gulpPlugins.postcss([
        require('autoprefixer')({ browsers: config.autoprefixerOpt })
        require('cssnano')({ autoprefixer: false })
      ])

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[sassAll]:')
