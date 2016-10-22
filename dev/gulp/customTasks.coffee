####################
### custom tasks ###
####################

module.exports = (gulp, gulpPlugins, config, utils)->
  # indexSprites
  utils.createSpritesTask 'indexSprites', "#{config.assetsDir}/img", "#{config.assetsDir}/css", 'sprites', '../img/sprites.png', true

  # lib.js
  # utils.createJsConcatTask(
  #   'concatLibJs'
  #   [ "#{config.srcDir}/#{config.assetsDir}/js/_lib/**/*" ]
  #   "#{config.publishDir}/#{config.assetsDir}/js"
  #   'lib'
  # )

  # index.js
  # utils.createCoffeeExtractTask(
  #   'indexJs'
  #   [
  #     "#{config.srcDir}/#{config.assetsDir}/js/_init.coffee"
  #     "#{config.srcDir}/#{config.assetsDir}/js/_index/index.coffee"
  #   ]
  #   "#{config.publishDir}/#{config.assetsDir}/js"
  #   'index'
  # )

  # common.js
  # utils.createBrowserifyTask(
  #   'commonJs'
  #   [ "#{config.srcDir}/#{config.assetsDir}/js/_common.coffee" ]
  #   [
  #     "#{config.srcDir}/#{config.assetsDir}/js/_utils/**/*"
  #     "#{config.srcDir}/#{config.assetsDir}/js/_glsl/**/*"
  #   ]
  #   "#{config.publishDir}/#{config.assetsDir}/js"
  #   'common'
  # )

  # lib.js
  utils.createWebpackJsTask(
    'libJs'
    [ "#{config.srcDir}/#{config.assetsDir}/js/_lib.coffee" ]
    []
    "#{config.publishDir}/#{config.assetsDir}/js"
    'lib'
  )

  # common.js
  utils.createWebpackJsTask(
    'commonJs'
    [ "#{config.srcDir}/#{config.assetsDir}/js/_common.coffee" ]
    [
      "#{config.srcDir}/#{config.assetsDir}/js/_utils/**/*"
      "#{config.srcDir}/#{config.assetsDir}/js/_glsl/**/*"
    ]
    "#{config.publishDir}/#{config.assetsDir}/js"
    'common'
  )
