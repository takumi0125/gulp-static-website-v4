####################
### custom tasks ###
####################

module.exports = (gulp, gulpPlugins, config, utils)->
  # indexSprites
  # utils.createSpritesTask 'indexSprites', "#{config.assetsDir}/img", "#{config.assetsDir}/css", 'sprites', '../img/sprites.png', true

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
  #   [ "#{config.srcDir}/#{config.assetsDir}/js/_common/common.js" ]
  #   "#{config.publishDir}/#{config.assetsDir}/js"
  #   'common'
  # )

  # common2.js
  # utils.createWebpackJsTask(
  #   'commonJs2'
  #   [ "#{config.srcDir}/#{config.assetsDir}/js/_common2/common.js" ]
  #   [
  #     "#{config.srcDir}/#{config.assetsDir}/js/_common2/*"
  #   ]
  #   "#{config.publishDir}/#{config.assetsDir}/js"
  #   'common2'
  # )
