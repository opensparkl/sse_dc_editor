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
 * Mixin containing helper functions for NodeContainer, NodeBasic and
 * NodeOperation.
 */
import Type from '../util/type'
import conf from '../config'
import vuex from 'vuex'
import Vue from 'vue'

export default {
  props: {
    'id': {
      type: String,
      required: true
    }
  },
  computed: {
    ...vuex.mapGetters([
      'selected',
      'selectedId',
      'rootId',
      'nodes',
      'errors'
    ]),

    node () {
      return this.nodes[this.id]
    },

    type () {
      return Type.is(this.node)
    },

    errorList () {
      return this.errors[this.id] || []
    },

    errorIcon () {
      if (this.errorList.length === 0) {
        return ''
      }

      var errors = this.errorList
        .filter(e => e.errorType === 'error')

      return errors.length > 0 ? 'error' : 'warning'
    },

    icon () {
      return 'fa fa-fw ' +
        (conf.components[this.node.tag] || 'fa-question')
    },

    nodeClass () {
      return [
        'sparkl-node',
        this.node.tag,
        this.type,
        this.errorIcon,
        {
          'ghost': this.node.is_ghost,
          'selected': this.selected === this.id
        }
      ]
    }
  },
  methods: {
    cleanErrors (id) {
      this.$store.commit('deleteErrors', id)
    },

    mouseover () {
      this.$store.state.nodeOverId = this.id
    },

    mouseleave () {
      this.$store.state.nodeOverId = null
    },

    select (id) {
      id = id || this.id

      if (this.selectedId !== id) {
        this.$store.commit('selectStruct', id)
      }
    },

    remove (id) {
      if (this.selectedId !== id) {
        this.$store.commit('unselectStruct', id)
      }

      if (this.rootId === id) {
        this.$store.dispatch('createEmpty')
      } else {
        if (this.node.tag === 'service' || this.node.tag === 'field') {
          if (!this.node.is_ghost) {
            Vue.set(this.node, 'is_ghost', true)
            return
          }
        }

        this.$store.commit('deleteStruct', id)
      }
    },

    unselect (event) {
      if (this.type === 'container' && this.selectedId) {
        this.$store.commit('unselectStruct')
      }

      if (event) {
        event.cancelBubble = true
      }
    }
  }
}
