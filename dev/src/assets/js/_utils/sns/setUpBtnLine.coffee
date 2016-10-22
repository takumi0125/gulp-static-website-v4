#
# setUpBtnLine
# require jquery
#

module.exports = ($btn, text, shareURL = '')->
  url = 'http://line.me/msg/text/?'

  if shareURL is ''
    url += "#{encodeURIComponent(text)}"
  else
    url += "#{encodeURIComponent(text)}\n#{encodeURIComponent(shareURL)}"

  $btn.on 'click', (e)->
    e.preventDefault()
    e.stopPropagation()
    window.open url, 'lineShare'
    return
