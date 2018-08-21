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
 * Class for managing json tree model.
 */
import _ from 'lodash'
import Type from './type'
import util from './index'
import parser from './parser'
import Vue from 'vue'
import errorTypes from './tree_error'

const order = {
  'prop': 1,
  'service': 2,
  'field': 3,
  'notify': 4,
  'solicit': 4,
  'request': 4,
  'consume': 4,
  'folder': 5,
  'mix': 5
}

var IdGenerator = function (prefix) {
  const JAN_1_2016 = 1420070400000
  const rn = () => Math.floor(Math.random() * 10e6).toString(36)

  let time = Math.abs(Date.now() - JAN_1_2016).toString(36)
  let p = prefix + '-' + time + '-'
  let next = 0

  return () => p + rn() + '-' + (next++).toString()
}

const Index = IdGenerator('ui')

const TRAVERSE = window.TRAVERSE = {
  CONTINUE: 0,
  STOP_BRANCH: 1,
  STOP_TRAVERSE: 2
}
/**
 *
 * @param nodes
 * @param id
 * @param callback
 * @param params
 */
var traverseModel = function (nodes, id, callback, params) {
  if (!nodes || !id || !callback) {
    return false
  }

  params = params || {level: 0, parent: null, id: id}

  var node = Tree.getStruct(nodes, id)
  var next = callback(node, params)

  if (next === TRAVERSE.STOP_BRANCH || next === TRAVERSE.STOP_TRAVERSE) {
    return next
  }

  if (Array.isArray(node.content)) {
    for (var i = 0; i < node.content.length; i++) {
      var childId = node.content[i]

      next = traverseModel(nodes, childId, callback, {
        id: childId,
        parent: node,
        level: params.level + 1
      })

      if (next === TRAVERSE.STOP_TRAVERSE) {
        return TRAVERSE.STOP_TRAVERSE
      }
    }
  }
}

var walk = function (json, callback, parent) {
  if (!json || !callback) return

  if (callback(json, parent || null) === false) {
    return
  }

  if (Array.isArray(json.content)) {
    for (var i = 0; i < json.content.length; i++) {
      var item = json.content[i]

      if (typeof item === 'object') {
        walk(json.content[i], callback, json)
      }
    }
  }
}
/**
 * Simply removes value if it is array
 * @param array
 * @param value
 * @returns {boolean}
 */
var removeValue = function (array, value) {
  if (Array.isArray(array)) {
    var index = array.indexOf(value)

    if (index !== -1) {
      array.splice(index, 1)
      return true
    }
  }

  return false
}

/**
 * Assebles JSON object from flat Tree
 */
var assembleJSON = function (nodes, id) {
  var attr = {}
  var node = nodes[id]

  if (!node || node.is_ghost) {
    return null
  }

  for (var i in node.attr) {
    if (node.attr.hasOwnProperty(i)) {
      var value = node.attr[i]

      if (Array.isArray(value)) {
        if (i === 'fields' || i === 'mask') {
          value = value.map(j => nodes[j].attr.name)
        }

        attr[i] = value.join(' ')
      } else {
        attr[i] = value
      }
    }
  }

  var content

  if (node.value) {
    content = [node.value]
  } else {
    content = node.content
      .map(id => assembleJSON(nodes, id))
      .filter(node => !!node)
  }
  return {
    tag: node.tag,
    attr: attr,
    content: content
  }
}

var filterDuplicateChildNodes = (nodes, parent, name, type) => {
  return parent.content.filter(i => {
    var node = nodes[i]
    return Type.is(node, type) && node.attr.name === name
  })
}

var Tree = {
  Index: Index,
  order,
  errorTypes: errorTypes,
  /**
   * Returns tree root
   * @param nodes
   * @returns {*}
   */
  getRoot (nodes) {
    for (var i in nodes) {
      if (nodes[i].is_root) return nodes[i]
    }

    return null
  },

  searchUp (nodes, start, criteria = {}, params = {}) {
    var results = []
    var limit = params.limit || Number.MAX_VALUE

    var startNode = this.getStruct(nodes, start)
    var node = params.skipSiblings
      ? nodes[startNode.parent_id]
      : startNode

    while (node) {
      var siblings = this.siblings(nodes, node, criteria)

      results = results.concat(siblings)

      if (results.length >= limit) {
        return results.slice(0, limit)
      }

      node = nodes[node.parent_id]
    }

    return results
  },

  searchDown (nodes, start, criteria, params) {
    var results = []
    var limit = params.limit || 0
    var startNode = this.getStruct(nodes, start)
    var node = params.skipSiblings
      ? startNode
      : nodes[startNode.parent_id]

    traverseModel(nodes, node, (current) => {
      if (current.content) {
        var children = this.children(nodes, current)
        var filtered = this.$filter(children, criteria)

        results = results.concat(filtered)

        if (limit > 0 && results.length >= limit) {
          results = results.slice(0, limit)
          return TRAVERSE.STOP_TRAVERSE
        }
      }
    })

    return results
  },
  /**
   * Returns the node from the tree collection
   * To make sure that the node is not a clone and exists in a tree
   * objects are be tested for having object.attr.id value
   *
   * @param nodes   {object}
   * @param id      {string|object}
   * @returns       {object|null}
   */
  getStruct (nodes, selector) {
    if (typeof selector === 'string') {
      return nodes[selector]
    }

    if (typeof selector === 'object' && selector.tag) {
      return nodes[selector.attr.id]
    }

    return null
  },
  /**
   * Traverses down the tree from root (ordered)
   * @param nodes     {object} - collection of the tree elements
   * @param id    {object|string} - identifier of the root element
   * @param callback  {function}
   */
  traverse (nodes, id, callback) {
    return traverseModel(nodes, id, callback, null)
  },

  create (nodes, payload, params = {}) {
    var node = _.assign({}, payload)

    _.defaultsDeep(node, {
      attr: {
        id: Index()
      },
      content: []
    })

    if (!node.attr.name && node.tag !== 'grant') {
      var name = node.tag || ''

      node.attr.name = name === 'field'
        ? name.toUpperCase()
        : util.capitalize(name)
    }

    if (params.append) {
      Vue.set(nodes, node.attr.id, node)

      if (node.parent_id) {
        Tree.parent(nodes, node, node.parent_id)
      }
    }

    return node
  },

  children (nodes, selector, filter) {
    var node = this.getStruct(nodes, selector)
    var children = node && node.content
      ? node.content.map(id => nodes[id])
      : []

    return this.$filter(children, filter)
  },

  siblings (nodes, selector, filter) {
    var node = this.getStruct(nodes, selector)
    var parent = this.getStruct(nodes, node.parent_id)
    var siblings = parent && parent.content
      ? parent.content
          .filter(i => i !== node.attr.id)
          .map(i => nodes[i])
      : []

    return this.$filter(siblings, filter)
  },
  /**
   * Returns tree path to the struct
   * @param nodes
   * @param id
   * @param {function} filter
   * @returns {Array}
   */
  ancestors (nodes, selector, filter) {
    var node = this.getStruct(nodes, selector)
    var path = []

    if (node) {
      while (node) {
        path.push(node)
        node = nodes[node.parent_id]
      }

      if (filter) {
        return _.filter(path, _.matches(filter))
      }
    }

    return path
  },

  $filter (array, filter) {
    switch (typeof filter) {
      case 'undefined':
        return array
      case 'object':
        return _.filter(array, _.matches(filter))
      case 'function':
        return array.filter(filter)
      default:
        return array.filter(v => v === filter)
    }
  },
  /**
   * Returns node's parent object
   * @param nodes
   * @param nodeId
   * @param [newParentId] - If present, updates node's parent
   * @returns {*}
   */
  parent (nodes, nodeSelector, newParentSelector = null, params = {}) {
    var node = this.getStruct(nodes, nodeSelector)
    var parent = this.getStruct(nodes, node.parent_id)

    if (newParentSelector) {
      var nodeId = node.attr.id
      var nparent = this.getStruct(nodes, newParentSelector)
      var position = params.position || -1

      if (nparent) {
        if (params.hasOwnProperty('position')) {
          position = params.position

          if (parent && parent.attr.id === nparent.attr.id) {
            var currentIndex = parent.content.indexOf(nodeId)

            if (currentIndex < position) {
              position -= 1
            }
          }
        }

        if (parent) {
          removeValue(parent.content, nodeId)
        }

        position < 0
          ? nparent.content.push(nodeId)
          : nparent.content.splice(position, 0, nodeId)

        node.parent_id = nparent.attr.id
        this.groupContent(nodes, nparent)

        return nparent
      }
    }

    return parent
  },
  /**
   * Removes any node with it's dependencies
   * @param nodes
   * @param selector
   */
  remove (nodes, selector) {
    var node = this.getStruct(nodes, selector)
    var nodeType = Type.is(node)
    var nodeName = node.attr.name
    var nodeId = node.attr.id

    var parent = this.getStruct(nodes, node.parent_id)
    var isSiblingClone = false

    var cloneFilter = (v) => {
      return Type.is(v.tag) === nodeType && v.attr.name === nodeName
    }

    if (nodeType === 'service' || nodeType === 'field') {
      var siblings = this.siblings(nodes, node, cloneFilter)
      isSiblingClone = siblings.length > 0
    }
    /**
     * Creating list of child nodes that should be deleted
     */
    traverseModel(nodes, nodeId, (n) => {
      delete nodes[n.attr.id]
    })

    delete nodes[nodeId]
    removeValue(parent.content, nodeId)
    /**
     * Cleaning dependencies
     */
    var isService = nodeType === 'service'
    var isField = nodeType === 'field'

    if (isService && !isSiblingClone) {
      traverseModel(nodes, parent, (n) => {
        var type = Type.is(n)

        if (type === 'container') {
          var clones = this.children(nodes, n, cloneFilter)

          if (clones.length > 0) {
            return TRAVERSE.STOP_BRANCH
          }
        }

        if (type === 'operation') {
          if (isService && n.attr.service === nodeName) {
            n.attr.service = ''
          }
        }
      })
    }

    if (isField) {
      traverseModel(nodes, parent, (n) => {
        var type = Type.is(n)
        /* console.log(n);
        if (type === 'container') {
          var clones = this.children(nodes, n, cloneFilter);

          if (clones.length > 0) {
            return TRAVERSE.STOP_BRANCH;
          }
        } */
        if (type === 'operation') {
          if (isField) {
            //  console.log('IS OP!');
            removeValue(n.attr.fields, nodeId)
            // removeValue(n.attr.mask, nodeId);
            return
          }
        //  if (isService && n.attr.service === nodeName) {
        //    n.attr.service = '';
        //  }
        }
      })
    }
  },

  isAncestorOf (nodes, nodeSelector, rootSelector) {
    var node = this.getStruct(nodes, nodeSelector)
    var start = this.getStruct(nodes, rootSelector) || this.getRoot(nodes)

    var query = {attr: {id: node.attr.id}}
    var results = this.searchUp(nodes, start, query, {limit: 1})

    return results.length > 0
  },

  addServiceRef (nodes, opSelector, serviceSelector) {
    var op = this.getStruct(nodes, opSelector)
    var service = this.getStruct(nodes, serviceSelector)

    if (!op) {
      return this.errorTypes.notFound('operation')
    }

    if (Type.isReply(op)) {
      op = this.getStruct(nodes, op.parent_id)
    }

    if (!service) {
      return 'Service does not exist'
    }

    if (!this.isAncestorOf(nodes, service, op)) {
      return this.errorTypes.scope('service', service.attr.name)
    }

    Vue.set(op.attr, 'service', service.attr.name)
  },

  addFieldRef (nodes, opSelector, fieldSelector) {
    var field = this.getStruct(nodes, fieldSelector)
    var op = this.getStruct(nodes, opSelector)

    if (!field) {
      return this.errorTypes.notFound(field.tag)
    }

    if (!field) {
      return this.errorTypes.notFound(op.tag)
    }

    var id = field.attr.id

    if (!this.isAncestorOf(nodes, field, op)) {
      return this.errorTypes.scope('field', field.attr.name)
    }

    if (Array.isArray(op.attr.fields)) {
      if (op.attr.fields.indexOf(id) === -1) {
        op.attr.fields.push(id)
      }
    } else {
      Vue.set(op.attr, 'fields', [id])
    }

    this.sortFeilds(nodes, opSelector)
  },

  sortFeilds (nodes, nodeSelector) {
    var node = this.getStruct(nodes, nodeSelector)
    var fields = (node.attr.fields || []).map(i => nodes[i])

    var sorted = fields.sort((a, b) => {
      var nameA = a.attr.name
      var nameB = b.attr.name

      if (nameA === nameB) {
        return 0
      }

      var isAUppercase = nameA === nameA.toUpperCase()
      var isBUppercase = nameB === nameB.toUpperCase()

      if (isAUppercase !== isBUppercase) {
        return isAUppercase ? -1 : 1
      }

      return (nameA < nameB ? -1 : 1)
    })

    Vue.set(node.attr, 'fields', sorted.map(v => v.attr.id))
  },

  groupContent (nodes, parentSelector) {
    var parent = this.getStruct(nodes, parentSelector)
    var content = parent.content.map(i => nodes[i])
    var ordered = []
    var groups = []

    for (var i = 0; i < content.length; i++) {
      var node = content[i]
      var index = order[node.tag] || 0

      groups[index] = (groups[index] || []).concat(node.attr.id)
    }

    for (var j = 0; j < groups.length; j++) {
      var group = groups[j]
      if (group) {
        ordered = ordered.concat(group)
      }
    }

    Vue.set(parent, 'content', ordered)
  },

  json (nodes, nodeId) {
    var root = nodeId
      ? this.getStruct(nodes, nodeId)
      : this.getRoot(nodes)

    if (!root) {
      throw new Error('Root is undefined (Tree.json)')
    }

    return assembleJSON(nodes, root.attr.id)
  },

  populate (json, callback) {
    var nodes = {}
    var root = null

    walk(json, (child, parent) => {
      if (child.tag === 'parsererror') {
        if (callback) {
          callback({
            type: 'Parse error',
            xml: child,
            json: json
          })
        }

        return false
      }

      if (!child.attr.id) {
        child.attr.id = Index()
      }

      var payload = {
        tag: child.tag,
        attr: child.attr,
        is_root: !parent
      }

      if (parent) {
        payload.parent_id = parent.attr.id
      }

      if (payload.tag === 'prop') {
        payload.value = child.value || child.content[0] || ''
      }

      var node = this.create(nodes, payload, {append: true})

      if (node.is_root) {
        root = node
      }

      nodes[node.attr.id] = node
    })

    if (!root) {
      return callback({
        type: 'No root',
        message: 'Root node was not found in the tree'
      })
    }

    for (var i in nodes) {
      if (nodes.hasOwnProperty(i)) {
        var node = nodes[i]
        var type = util.type.is(node)

        if (type === 'operation') {
          // @todo: do the same for mask fields
          if (typeof node.attr.fields === 'string') {
            var names = node.attr.fields.split(' ')
            var indexes = names.map(name => {
              var query = {
                tag: 'field',
                attr: {name}
              }

              var field = this.searchUp(nodes, node.attr.id, query, {limit: 1})[0]

              if (!field) {
                field = this.create(nodes, {
                  tag: 'field',
                  attr: {
                    name
                  },
                  is_ghost: true,
                  parent_id: root.attr.id
                }, {append: true})
              }

              return field.attr.id
            })

            node.attr.fields = indexes
          }

          var serviceNameString = (node.attr.service || '') + ' ' + (node.attr.clients || '')
          var serviceNames = serviceNameString.split(/\s+/gi).filter(v => v.trim())

          for (let i = 0; i < serviceNames.length; i++) {
            var name = serviceNames[i]
            var query = {
              tag: 'service',
              attr: {
                name
              }
            }

            var service = Tree
              .searchUp(nodes, node.attr.id, query, {limit: 1})[0]

            if (!service) {
              service = this.create(nodes, {
                tag: 'service',
                attr: {
                  name
                },
                is_ghost: true,
                parent_id: root.attr.id
              }, {
                append: true
              })
            }
          }
        }
      }
    }

    if (callback) {
      callback(null, nodes)
    }
  },

  xml (nodes, rootId, params = {}) {
    var json = this.json(nodes, rootId)
    return parser.structJson2Xml(json, params)
  },

  xmlString (nodes, rootId, params = {}) {
    var xml = this.xml(nodes, rootId, params)
    var text = parser.xml2String(xml)

    // if (params.prettify) {
    //  return util.prettify.xml(text);
    // }

    return text
  },
  filterDuplicateChildNodes
}

module.exports = Tree
