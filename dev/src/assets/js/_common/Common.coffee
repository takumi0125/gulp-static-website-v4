utils = require '../_utils/utils'

class Common
  constructor: ->
    @$window = $ window
    @$html = $ 'html'
    @$body = $ 'body'


    # check device
    utils.md = utils.checkDevice @$html



module.exports = Common
