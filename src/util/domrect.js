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
const TO_DEG = 180 / Math.PI

var depth = el => {
  var depth = 0

  while (el && el.nodeName !== 'BODY') {
    depth++
    el = el.parentNode
  }

  return depth
}

var getBorderData = el => {
  return {
    el,
    id: el.id,
    rect: el.getBoundingClientRect(),
    depth: depth(el)
  }
}

var rectCenter = rect => {
  return {
    left: rect.left + 0.5 * rect.width,
    top: rect.top + 0.5 * rect.height
  }
}

var angleBetweenPoints = (p1, p2) => {
  var delta = {
    left: p1.left - p2.left,
    top: p1.top - p2.top
  }

  return Math.atan2(delta.left, delta.top) * TO_DEG
}

var distance = (point1, point2) => {
  var dpLeft = point1.left - point2.left
  var dpTop = point1.top - point2.top

  return Math.sqrt(dpLeft * dpLeft + dpTop * dpTop)
}

var borders = selector => {
  var folders = document.body.querySelectorAll(selector)
  var borders = {}

  for (var i = 0; i < folders.length; i++) {
    var el = folders[i]
    var id = el.id

    borders[id] = getBorderData(el)
  }

  return borders
}

var isInside = (p, rect) => {
  return rect.left < p.left &&
    (rect.left + rect.width) > p.left &&
    rect.top < p.top &&
    (rect.top + rect.height) > p.top
}

export default {depth, borders, isInside, getBorderData, rectCenter, distance, angleBetweenPoints}
