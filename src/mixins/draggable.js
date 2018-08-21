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
 *
 * Mixin responsible for dragging nodes from left sidebar to mix editor.
 */
import domrect from '../util/domrect'
import tree from '../util/tree'

var tmpCacheBoxes = {}

var getTmpCachedBox = (id) => {
  var box = tmpCacheBoxes[id] || null

  if (!box) {
    var el = document.querySelector('.sparkl-node#' + id)
    if (el) {
      box = tmpCacheBoxes[id] = domrect.getBorderData(el)
    }
  }

  return box
}

var removeDirectionClasses = el => {
  if (el) {
    el.classList
      .remove('is-of-left', 'is-of-right', 'is-of-top', 'is-of-bottom')
  }
}

var setDirectionClass = (el, x, y) => {
  var isFolder = el.classList.contains('container')
  if (isFolder) {
    el.classList.add(y > 0 ? 'is-of-bottom' : 'is-of-top')
  } else {
    el.classList.add(x > 0 ? 'is-of-right' : 'is-of-left')
  }
}

export default {
  data () {
    return {
      drag: {
        cachedBoxes: []
      },
      borders: {}
    }
  },
  methods: {
    dragCleanCache () {
      tmpCacheBoxes = {}
      this.drag = {cachedBoxes: []}
      this.borders = {}
    },
    dragClean () {
      if (this.drag.closest) {
        removeDirectionClasses(this.drag.closest.box.el)
        this.drag.closest = null
      }

      if (this.drag.target) {
        this.drag.target.el.classList.remove('is-over-node')
        this.drag.target = null
      }
    },
    dragMove (event) {
      var targetBox = null
      var left = event.mousemove.clientX
      var top = event.mousemove.clientY - event.start.scroll.y + window.scrollY
      var point = {left, top}

      for (var i in this.borders) {
        var box = this.borders[i]

        if (targetBox && targetBox.depth > box.depth) {
          continue
        }

        if (domrect.isInside(point, box.rect)) {
          targetBox = box
        }
      }

      if (targetBox === null) {
        if (this.drag.target) {
          this.dragClean()
        }

        return
      }

      if (targetBox === this.drag.target) {
        var closest = null

        this.drag.cachedBoxes.forEach(box => {
          var boxRect = box.rect
          var boxCenter = domrect.rectCenter(boxRect)
          var dist = domrect.distance(point, boxCenter)

          if (!closest || closest.dist > dist) {
            var angle = domrect.angleBetweenPoints(boxCenter, point) + 180
            closest = {dist, box, angle}
          }
        })

        if (closest) {
          closest.x = closest.angle < 180 ? 1 : -1
          closest.y = closest.angle > 90 && closest.angle < 270 ? -1 : 1

          if (this.drag.closest) {
            removeDirectionClasses(this.drag.closest.box.el)
          }

            // console.log(this.drag.id, closest.box.id, this.selectedId);

          if (this.drag.id !== closest.box.id) {
              // if ()
            setDirectionClass(closest.box.el, closest.x, closest.y)
          }

          this.drag.closest = closest
        }
        return
      }

      var node = this.nodes[targetBox.id]
      var contentBoxes = []

      node.content.forEach(id => {
        var contentItem = this.nodes[id]
        /* Filtering nodes of different types, except folders and mixes; */
        var approved = tree.order[this.drag.tag] === tree.order[contentItem.tag]
        // this.drag.tag === contentItem.tag
        // || (isContainer && type.is(contentItem) === 'container');

        if (approved) {
          /* Using lazy caching to cache/retrieve border-box */
          var box = getTmpCachedBox(id)
          if (box) {
            contentBoxes.push(box)
          }
        }
      })

      this.drag.cachedBoxes = contentBoxes
      this.dragClean()

      if (targetBox) {
        this.drag.target = targetBox
        this.drag.target.el.classList.add('is-over-node')
      }
    }
  }
}
