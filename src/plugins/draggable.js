/**
 * Copyright 2018 SPARKL Limited
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
var cache
var config = {}

if (!('path' in window.MouseEvent.prototype)) {
  Object.defineProperty(window.MouseEvent.prototype, 'path', {
    get: function () {
      var path = []
      var currentElem = this.target

      while (currentElem) {
        path.push(currentElem)
        currentElem = currentElem.parentElement
      }

      if (path.indexOf(window) === -1 && path.indexOf(document) === -1) {
        path.push(document)
      }

      if (path.indexOf(window) === -1) {
        path.push(window)
      }

      return path
    }
  })
}

var distance = (x1, y1, x2, y2) => {
  return Math.sqrt((x2 -= x1) * x2 + (y2 -= y1) * y2)
}

  /* temp. solution */
var emit = (vnode, name, data) => {
  var handlers = (vnode.data && vnode.data.on) ||
      (vnode.componentOptions && vnode.componentOptions.listeners)

  if (handlers && handlers[name]) {
    var fn = handlers[name].fn || handlers[name].fns
    fn(data)
  }
}

var stop = event => {
  event.preventDefault()
  event.stopPropagation()
}

  /* Should be in the very end of styles, to override everything */
setTimeout(() => {
  document.head.innerHTML += `
      <style type="text/css">
        .is-dragging {
          display: block;
          position: absolute;
          transition: none;
          z-index: 9999;
          margin: 0;
        }
      </style>
    `
}, 1)

var move = (el, borders) => {
  var css = ''
  for (var i in borders) {
    css += i + ':' + borders[i] + 'px;'
  }

  el.style.cssText = css
}

var mousemove = (event) => {
  var { offset, rect, click } = cache.start

  var rectangle = {
    left: event.pageX - offset.left,
    top: event.pageY - offset.top,
    height: rect.height,
    width: rect.width
  }

  var initialized = !!cache.mousemove

  cache.rect = rectangle
  cache.mousemove = event
  cache.distance = distance(event.pageX, event.pageY, click.left, click.top)

  if (!initialized) {
    move(cache.clone, rectangle)
  } else if (cache.distance > cache.stickness) {
    if (cache.stickness !== 0) {
      cache.stickness = 0
    }

    move(cache.clone, rectangle)
    emit(cache.vnode, 'drag-move', cache)
  }

  stop(event)
}

var mouseup = event => {
  cache.mouseup = event
  emit(cache.vnode, 'drag-stop', cache)
  cache.el.classList.remove('drag-source')

  document.removeEventListener('mousemove', mousemove)
  document.removeEventListener('mouseup', mouseup)
  document.body.removeChild(cache.clone)

  cache = null
  stop(event)
}

var onMousedown = function (params, el, vnode, event) {
  if (event.which !== 1) {
    return 0
  }

  var rect = el.getBoundingClientRect()
  var clone = el.cloneNode(true)

  cache = {
    el,
    clone,
    vnode,
    params: this.util.extend(params),
    stickness: Math.max(params.stickiness || 0, 0),
    start: {
      rect,
      click: {
        left: event.pageX,
        top: event.pageY
      },
      offset: {
        left: event.clientX - rect.left,
        top: event.clientY - rect.top
      },
      scroll: {
        x: window.scrollX,
        y: window.scrollY
      }
    },
    mousedown: event
  }

  cache.el.classList.add('drag-source')
  cache.clone.classList.add('is-dragging', 'drag-clone')
  document.body.appendChild(cache.clone)

  mousemove(event)
  emit(vnode, 'drag-start', cache)

  document.addEventListener('mousemove', mousemove)
  document.addEventListener('mouseup', mouseup)

  stop(event)
}

var install = (Vue, opts) => {
  Vue.directive('draggable', {
    bind: function (el, binding, vnode) {
      var params = Vue.util.extend({}, binding.value || {})
      var handler = onMousedown.bind(Vue, params, el, vnode)

      el.addEventListener('mousedown', handler)
    }
  })
}

export default {
  install,
  config
}
