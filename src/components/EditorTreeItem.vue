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
  <div class="editor-tree-item">
    <div
      class="eti-name"
      :class="{selected: selectedId === node.attr.id}"
      @click.stop="select">
      <icon :name="iconName"/>{{title}}
    </div>
    <div
      v-if="opened && children.length > 0"
      class="eti-content">
      <div
        v-if="props.length > 0"
        class="eti-name">
        <div @click="showProps = !showProps">
          <icon name="plus-square-o"/>Properties
        </div>
        <div
          v-if="showProps"
          class="eti-content">
          <editor-tree-item
            v-for="(child, i) in props"
            :node="child"
            :key="child.attr.id"/>
        </div>
      </div>
      <editor-tree-item
        v-for="(child, i) in nonprops"
        :node="child"
        :key="child.attr.id"/>
    </div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex'
import { icons } from '../config'
import type from '../util/type'

export default {
  name: 'EditorTreeItem',
  props: ['node', 'visible'],
  data () {
    return {
      showProps: false,
      opened: this.visible || false
    }
  },
  computed: {
    ...mapGetters([
      'root',
      'nodes',
      'selectedId',
      'selected'
    ]),
    iconName () {
      return icons[this.node.tag] || 'question'
    },
    title () {
      return this.node.attr.name || `<${this.node.tag}>`
    },
    children () {
      return this.node.content.map(i => this.nodes[i])
    },
    props () {
      return this.children.filter(v => v.tag === 'prop')
    },
    nonprops () {
      return this.children.filter(v => v.tag !== 'prop')
    }
  },
  methods: {
    select () {
      var id = this.node.attr.id

      if (type.isRenderable(this.node.tag)) {
        this.opened = true

        if (id === this.selectedId) {
          var focusId = type.isReply(this.node.tag)
            ? this.node.parent_id
            : this.node.attr.id

          var el = document.querySelector('#' + focusId)
          var rect = el.getBoundingClientRect()
          var top = rect.top + window.scrollY - 10

          window.scroll({ top: top, left: 0, behavior: 'smooth' })
        } else {
          this.$store.commit('selectStruct', this.node.attr.id)
        }
      } else {
        if (this.node.tag === 'prop') {
          this.$modal.show('props', {
            focus: id
          })
        }
        // console.log('pop');
      }
    }
  }
}
</script>
<style lang="scss">
  .editor-tree-item {
    color: #444;

    .eti-name {
      padding: 3px;
      cursor: pointer;

      i {
        //vertical-align: middle;
        padding: 3px;
        font-size: 8px;
      }

      &.selected {
        border-top-left-radius: 3px;
        border-bottom-left-radius: 3px;
        background: #4091D2;
        color: white;
      }
    }

    .eti-content {
      padding-left: 10px;
    }
  }

</style>
