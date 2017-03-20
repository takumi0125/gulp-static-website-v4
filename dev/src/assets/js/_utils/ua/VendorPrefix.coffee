#
# vendorPrefix (use MobileDetect)
#

module.exports = (->
  styles = window.getComputedStyle(document.documentElement, '')
  pre = (Array.prototype.slice
    .call(styles)
    .join('')
    .match(/-(moz|webkit|ms)-/) || (styles.OLink is '' and ['', 'o'])
  )[1]
  return {
    dom: ('WebKit|Moz|MS|O').match(new RegExp('(' + pre + ')', 'i'))[1]
    lowercase: pre
    css: '-' + pre + '-'
    js: pre[0].toUpperCase() + pre.substr(1)
  }
)()
