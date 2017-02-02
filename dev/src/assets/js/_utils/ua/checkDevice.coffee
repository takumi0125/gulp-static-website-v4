#
# checkDeivce
#

module.exports = ($html)->
  md = new MobileDetect(navigator.userAgent)

  if md.tablet()
    $html.addClass 'tablet'
  else if md.phone()
    $html.addClass 'mobile'
  else
    $html.addClass 'desktop'

  return md
