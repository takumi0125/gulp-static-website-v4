####################
### custom tasks ###
####################

module.exports = (gulp, gulpPlugins, config, utils)->
  # indexSprites
  utils.createSpritesTask 'indexSprites', "#{config.assetsDir}/img", "#{config.assetsDir}/css", 'sprites', '../img/sprites.png', true

  # lib.js
  utils.createJsConcatTask(
    'concatLibJs'
    [ "#{config.srcDir}/#{config.assetsDir}/js/_lib/**/*" ]
    "#{config.publishDir}/#{config.assetsDir}/js"
    'lib'
  )

  # index.js
  # utils.createCoffeeExtractTask(
  #   'indexJs'
  #   [
  #     "#{config.srcDir}/#{config.assetsDir}/js/_index/**/*"
  #   ]
  #   "#{config.publishDir}/#{config.assetsDir}/js"
  #   'index'
  # )

  # common.js
  utils.createWebpackJsTask(
    'commonJs'
    [ "#{config.srcDir}/#{config.assetsDir}/js/_common/init.coffee" ]
    [
      "#{config.srcDir}/#{config.assetsDir}/js/_utils/**/*"
      "#{config.srcDir}/#{config.assetsDir}/js/_common/**/*"
    ]
    "#{config.publishDir}/#{config.assetsDir}/js"
    'common'
  )

  # index.js
  utils.createWebpackJsTask(
    'indexJs'
    [ "#{config.srcDir}/#{config.assetsDir}/js/_index/init.coffee" ]
    [
      "#{config.srcDir}/#{config.assetsDir}/js/_utils/**/*"
      "#{config.srcDir}/#{config.assetsDir}/js/_index/**/*"
    ]
    "#{config.publishDir}/#{config.assetsDir}/js"
    'index'
  )
