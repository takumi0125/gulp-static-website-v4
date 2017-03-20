#
# transitionend
#

module.exports = (->
  el = document.createElement 'p'
  transitions =
    transition: 'transitionend'
    OTransition: 'oTransitionEnd'
    MozTransition: 'transitionend'
    WebkitTransition: 'webkitTransitionEnd'

  for key, value of transitions
    if el.style[key]? then return transitions[key]

  return 'transitionend'
)()
