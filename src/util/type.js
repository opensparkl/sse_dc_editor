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
var types = {
  service: ['service', 'link', 'node'],
  operation: ['notify', 'solicit', 'request', 'consume', 'reply', 'response'],
  container: ['folder', 'mix']
}

var rendered = ['operation', 'service', 'field', 'container']
var extendable = ['request', 'consume', 'solicit']

/**
 * Gets tag out of struct
 * @param {string|object} type
 * @returns {string}
 */
const getType = function (type) {
  return typeof type === 'object' && type.hasOwnProperty('tag')
    ? type.tag
    : type
}

/**
 * Returns generalized type of the element, example:
 *   Notify --> Operation
 *   Link --> Service
 *
 * @param {string|object} type
 * @returns {string}
 */
const is = function (type, compared) {
  if (type) {
    var $type = getType(type)

    for (var i in types) {
      if (types.hasOwnProperty(i) && types[i].indexOf($type) !== -1) {
        return i
      }
    }

    if (typeof compared !== 'undefined') {
      return type === compared
    }

    return $type
  }
}

/**
 * True for nodes that should be rendered
 * @param type
 * @returns {boolean}
 */
const isRenderable = function (type) {
  return rendered.indexOf(is(getType(type))) !== -1
}

/**
 * True for operations that can have replies and responses
 * @param type
 * @returns {boolean}
 */
const isExtendable = function (type) {
  return extendable.indexOf(getType(type)) !== -1
}

/**
 * True for replies and responses
 * @param type
 * @returns {boolean}
 */
const isReply = function (type) {
  var $type = getType(type)
  return $type === 'reply' || $type === 'response'
}

module.exports = {is, isReply, isRenderable, isExtendable}
