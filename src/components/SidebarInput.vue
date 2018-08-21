<!--
  Copyright 2018 SPARKL Limited

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<template>
  <div class="input-field filled">
    <label>{{params.name}}</label>
    <SelectInput
      :value="value"
      :list="datalist"
      @focus="focus"
      @blur="unfocus"
      @input="input"/>
  </div>
</template>
<script>
import Vue from 'vue'
import Tree from '../util/tree'
import util from '../util'
import { mapGetters } from 'vuex'
import SelectInput from './SelectInput'

export default {
  name: 'SidebarInput',
  props: {
    params: {
      type: Object,
      required: true
    },
    value: {
      type: String,
      default: ''
    }
  },
  data () {
    return {
      cache: {}
    }
  },
  components: {
    SelectInput
  },
  computed: {
    datalist () {
      if (this.params.name === 'service') {
        return Tree
            .searchUp(this.nodes, this.selected, v => v.tag === 'service')
            .map(v => v.attr.name)
      } else if (this.params.datalist) {
        return this.params.datalist
      } else {
        return []
      }
    },
    ...mapGetters([
      'nodes',
      'selected'
    ])
  },
  methods: {
    getDependantOperations (service) {
      var {id, name} = service.attr
      var nodes = []

      Tree.traverse(this.nodes, service.parent_id, tnode => {
        if (util.type.is(tnode) === 'container') {
          var operations = []
          var services = []

          Tree.children(this.nodes, tnode, item => {
            var type = util.type.is(item)

            if (type === 'service' && item.attr.name === name &&
              item.attr.id !== id) {
              services.push(item)
            }

            if (type === 'operation' && item.attr.service === name) {
              operations.push(item)
            }
          })

          if (services.length > 0) {
            return window.TRAVERSE.STOP_BRANCH
          }

          nodes = nodes.concat(operations)
        } else {
          return window.TRAVERSE.STOP_BRANCH
        }
      })

      return nodes
    },
    focus (event) {
      if (this.selected.tag === 'service') {
        var nodes = this.getDependantOperations(this.selected)
        if (nodes.length > 0) {
          this.cache.nodes = nodes
        }
      }
    },
    unfocus (event) {
      this.cache = {}
    },
    input (event) {
      event.key = this.params.name
      event.params = this.params

      this.$emit('update', event)
      Vue.set(this.selected.attr, event.key, event.value)

      if (this.selected.tag === 'service' && event.key === 'name') {
        if (this.cache.nodes) {
          this.cache.nodes.forEach(v => {
            v.attr.service = event.value
          })
        }
      }
    }
  }

}
</script>
