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
import prettify from './xml_pretify'
import parser from './parser'
import query from './query'
import type from './type'
import domrect from './domrect'

const randomNodeName = (() => {
  var keys = {}

  return key => {
    keys[key] = (keys[key] || 0) + 1
    return util.capitalize(key) + '-' + keys[key]
  }
})()

const util = {
  prettify,
  parser,
  domrect,
  query,
  type,
  capitalize (string) {
    if (typeof string === 'string' && string.length > 0) {
      return string.charAt(0).toUpperCase() + string.slice(1)
    }
    return string
  },

  wsSplit (string) {
    return string.split(/\s+/g).filter(v => !!v)
  },

  blobToXml (blob, callback) {
    var reader = new FileReader()

    reader.addEventListener('loadend', e => {
      var xml = parser.string2Xml(e.target.result)
      callback(xml)
    })

    reader.readAsText(blob)
  },

  stripSlashes (string) {
    return (string || '').replace(/(^[/]+|[/]+$)/gm, '')
  },

  attrsFor (node) {
    var attr = {}

    Array.prototype
      .slice.call(node.attributes)
      .forEach(v => {
        attr[v.name] = v.value
      })

    return attr
  },

  forEachElement (parent, selector, handler) {
    if (typeof handler !== 'function') return

    var elements = parent.querySelectorAll(selector)
    var length = elements.length

    for (var i = 0; i < length; i++) {
      handler(elements[i], i, elements)
    }
  },

  mapElements (parent, selector, handler) {
    var results = []

    this.forEachElement(parent, selector, (el) => {
      results.push(handler(el))
    })

    return results
  },

  download (text, title, ext) {
    var element = document.createElement('a')
    var href = 'data:text/plain;charset=utf-8,' + encodeURIComponent(text)

    element.setAttribute('href', href)
    element.setAttribute('download', title + '.' + ext)
    element.style.display = 'none'

    document.body.appendChild(element)
    element.click()
    document.body.removeChild(element)
  },
  randomNodeName
}

export default util
