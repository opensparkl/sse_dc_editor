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
import Vue from 'vue'
import _ from 'lodash'
import Tree from '../../util/tree'
import Type from '../../util/type'
import store from '../index'

var createMissingService = function (nodes, rootId, op) {
  var service = {
    tag: 'service',
    attr: {
      name: op.attr.service
    }
  }

  var services = Tree.searchUp(nodes, op.attr.id, service, {limit: 1})

  if (services.length === 0) {
    service = Vue.util.extend(service, {
      parent_id: rootId,
      is_ghost: true
    })

    store.commit('createStruct', service)
    return true
  }

  return false
}

var mutations = {
  createStruct (state, payload) {
    var nodes = state.nodes
    var node = Tree.create(nodes, payload, {append: true})

    if (payload.hasOwnProperty('$position')) {
      Tree.parent(nodes, node, node.parent_id, {
        position: payload.$position
      })
    }
  },

  updateStruct (state, {id, partial}) {
    var node = state.nodes[id]

    if (node) {
      _.merge(node, partial)
      Vue.set(state.nodes, id, node)
    }
  },

  moveStruct (state, {id, to, at}) {
    if (to) {
      const node = state.nodes[id]
      const parentId = node.parent_id
      const type = Type.is(node)

      Tree.parent(state.nodes, id, to, {position: at})

      if (type === 'operation' && node.attr.service) {
        createMissingService(state.nodes, state.rootId, node)
      }

      if (type === 'service') {
        const serviceName = node.attr.name
        const operations = []

        Tree.traverse(state.nodes, parentId, (child, params) => {
          const type = Type.is(child)

          if (type === 'operation' && child.attr.service === serviceName) {
            operations.push(child)
            return window.TRAVERSE.CONTINUE
          }
          /* If service with such name exists, stop traversion in the
            child folders
          */
          if (type === 'service' && child.attr.name === serviceName) {
            return window.TRAVERSE.STOP_BRANCH
          }
        })

        for (let i = 0; i < operations.length; i++) {
          const op = operations[i]
          /*
            Create a service if it is not an ancestor of the operations.
            Also there is no need to iterate futher, because service is
            created in the root
          */
          if (!Tree.isAncestorOf(state.nodes, node, op)) {
            var created = createMissingService(state.nodes, state.rootId, op)

            console.log('Created referenced service for ' + op.attr.name)

            if (created) {
              break
            }
          }
        }
      }

      if (type === 'field') {
        const operations = []
        const fieldId = node.attr.id
        const fieldName = node.attr.name

        Tree.traverse(state.nodes, parentId, (child, params) => {
          var childType = Type.is(child)

          if (childType === 'field' && child.attr.name === fieldName) {
            return window.TRAVERSE.STOP_BRANCH
          }

          if (childType === 'operation' && child.attr.fields) {
            var index = child.attr.fields.indexOf(fieldId)

            if (index !== -1) {
              /* Caching operation object and index in "fields" array */
              operations.push({
                index: index,
                op: child
              })
            }
          }
        })

        var field = null

        for (let i = 0; i < operations.length; i++) {
          const {op, index} = operations[i]
          const isAncestor = Tree.isAncestorOf(state.nodes, fieldId, op)

          if (!isAncestor) {
            if (!field) {
              field = Tree.create(state.nodes, {
                tag: 'field',
                attr: {
                  name: fieldName
                },
                is_ghost: true,
                parent_id: state.rootId
              }, {append: true})
            }

            op.attr.fields.splice(index, 1, field.attr.id)
          }
        }
      }
    } else {
      console.error('Please, specifiy the target for ' + id)
    }
  },

  deleteStruct (state, id) {
    Tree.remove(state.nodes, id)

    if (state.selectedId === id && !state.nodes[id]) {
      state.selectedId = null
    }
  },

  selectStruct (state, id) {
    if (state.selectedId) {
      store.commit('unselectStruct')
    }

    state.selectedId = id
  },

  unselectStruct (state) {
    if (state.selectedId) {
      var selected = state.nodes[state.selectedId]
      var isOperation = Type.is(selected.tag) === 'operation'

      if (isOperation && selected.attr.service) {
        createMissingService(state.nodes, state.rootId, selected)
      }

      state.selectedId = null
    }
  }
}

export default mutations
