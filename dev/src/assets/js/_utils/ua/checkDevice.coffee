#
# checkDeivce (use MobileDetect)
#

module.exports = ->
  md = new MobileDetect(navigator.userAgent)
  html = document.body.parentElement

  if md.mobile()
    html.classList.add 'mobile'

  else if md.tablet()
    html.classList.add 'tablet'

  else
    html.classList.add 'desktop'

  return md
