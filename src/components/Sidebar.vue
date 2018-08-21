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
  <div>
    <tab-header
      :list="['edit', 'settings']"
      @select="setTab"
      style="margin-top: 5px"/>
    <div style="padding-top: 20px;"/>
    <div
      v-if="selected && tab === 'edit'"
      style="padding: 5px">
      <template v-for="v in layout">
        <sidebar-input
          v-if="v.type === 'input'"
          :params="v"
          :key="selected.attr.id + v.name"
          :value="attr[v.name]"/>
        <div
          v-else-if="v.type === 'select'"
          class="input-select"
          :key="selected.attr.id + v.name">
          <label>{{v.name}}</label>
          <select
            :value="attr[v.name]"
            @change="update(v, $event)">
            <option
              v-for="(value, key) in v.options"
              :value="key"
              :selected="attr[v.name] === key">{{value}}</option>
          </select>
        </div>
      </template>

      <div v-if="selectedIsContainer"
           class="button full-width with-icon"
           @click="importInto">
        <i class="fa fa-fw fa-file"></i>
        Import into {{selected.tag}}
        <input
          style="display: none"
          type="file"
          ref="import"
          @change="importFile">
      </div>

      <div v-if="selected.tag === 'folder'"
          class="button full-width with-icon"
          @click="selected.tag = 'mix'">
        <i class="fa fa-fw fa-th"></i>
        Transform to mix
      </div>

      <div v-if="selected.tag === 'mix'"
          class="button full-width with-icon"
          @click="selected.tag = 'folder'">
        <i class="fa fa-fw fa-th"></i>
        Transform to folder
      </div>

      <div v-if="selected.tag === 'consume'"
           class="button full-width with-icon"
           @click="selected.tag = 'request'">
        <i class="fa fa-fw fa-random"></i>
        Transform to request
      </div>

      <div v-if="selected.tag === 'request'"
           class="button full-width with-icon"
           @click="selected.tag = 'consume'">
        <i class="fa fa-fw fa-random"></i>
        Transform to consume
      </div>

      <div class="button full-width with-icon"
           v-if="selected.is_ghost"
           @click="selected.is_ghost = false;">
        <i class="fa fa-check-circle fa-fw"></i>
        Approve {{selected.tag}}
      </div>

      <div class="button full-width with-icon"
           v-if="!selected.is_ghost"
           @click="showPropsModal">
        <i class="fa fa-fw fa-list"></i>
        Properties
      </div>

      <div class="button full-width with-icon"
           @click="showSourceModal">
        <i class="fa fa-fw fa-code"></i>
        Edit source
      </div>
    </div>

    <settings
      v-if="tab === 'settings'"
      style="padding: 5px"/>
    <div v-if="tab === 'tree'">
      <editor-tree/>
    </div>
  </div>
</template>
<script>
import _ from 'lodash'
import Vue from 'vue'
import vuex from 'vuex'
import layoutScheme from '../config/layouts'
import Layout from '../util/layout'
import Tree from '../util/tree'
import Settings from './Settings'
import TabHeader from './TabHeader'
import SidebarInput from './SidebarInput'
import SelectInput from './SelectInput'
import EditorTree from './EditorTree'
import {importFromFile} from '../helpers/importer'

var layout = Layout(layoutScheme)

export default {
  data () {
    return {
      tab: 'edit',
      services: []
    }
  },
  components: {Settings, TabHeader, SidebarInput, SelectInput, EditorTree},
  computed: {
    ...vuex.mapGetters([
      'nodes',
      'selected',
      'selectedIsContainer'
    ]),
    attr () {
      return this.selected.attr
    },
    layout () {
      if (this.selected) {
        if (this.selected.is_ghost === true) {
          return [{name: 'name', type: 'input'}]
        }

        return layout[this.selected.tag] || []
      }
      return []
    }
  },
  methods: {
    setTab (name) {
      this.tab = name
    },
    update (input, event) {
      var key = input.name
      var value = event.target.value

      Vue.set(this.selected.attr, key, value)
    },
    toggleContainerTag () {
      this.selected.tag = this.selected.tag === 'folder'
          ? 'mix'
          : 'folder'
    },
    importInto () {
      this.$refs.import.click()
    },
    importFile (event) {
      importFromFile(event.target.files[0], (error, nodes) => {
        if (error) {
          this.$notify(error)
        } else {
          var rootId = Tree.getRoot(nodes).attr.id
          var currentId = this.selected.attr.id
          var collection = _.assign({}, this.nodes, nodes)

          collection[rootId].is_root = false
          collection[currentId].content.push(rootId)

          this.$store.commit('setNodes', collection)
        }
      })
    },
    showPropsModal () {
      this.$modal.show('props', {
        focus: this.selectedId
      })
    },
    showSourceModal () {
      this.$modal.show('source')
    }
  }
}
</script>
