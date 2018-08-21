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
  <div :class="['sparkl-tree-node', classes]">
    <div
      class="sparkl-tree-title"
      :style="style"
      @click.stop="select(source.attr.path)" >
      <i
        :class="icon"
        @click.stop="open(source.attr.path)"></i>
      <span class="selectable">
        <i :class="icon2"/>
        {{source.attr.name}}
      </span>
    </div>
    <div
      v-if="isOpened"
      class="sparkl-tree-children">
      <sparkl-restore-item
        v-for="(child, i) in children"
        :key="i"
        :source="child"
        :class="'i-' + i"
        :level="level + 1"/>
    </div>
  </div>
</template>
<script>
import api from '../api'
import { mapGetters } from 'vuex'

export default {
  name: 'SparklRestoreItem',
  props: {
    source: {
      type: Object
    },
    level: {
      type: Number,
      default: 0
    }
  },
  data () {
    return {
      isOpened: false,
      style: {
        'padding-left': (5 + this.level * 20) + 'px'
      },
      children: []
    }
  },
  computed: {
    icon () {
      return this.isOpened
       ? 'fa fa-fw fa-minus-square-o opener'
       : 'fa fa-fw fa-plus-square-o opener'
    },
    icon2 () {
      return this.source.tag === 'folder'
        ? 'fa fa-fw fa-folder-o'
        : 'fa fa-fw fa-th'
    },
    ...mapGetters([
      'importer'
    ]),
    classes () {
      return {
        root: this.source.attr.path === '',
        selected: this.importer.path === this.source.attr.path
      }
    }
  },
  methods: {
    select (path) {
      this.importer.path = this.importer.path === path
        ? null
        : path
    },
    open (path) {
      if (this.isOpened) {
        this.isOpened = false
        this.children = []
      } else {
        api.content(path).then(response => {
          var content = response.data.content.filter(v => {
            return v.tag === 'folder' || v.tag === 'mix'
          })

          this.children = content
          this.isOpened = true
        })
      }
    }
  }
}
</script>
<style lang="scss" scoped>
.sparkl-tree-node {
  .sparkl-tree-title {
    position: relative;
    line-height: 24px;
    height: 24px;
    cursor: pointer;

    span, i {
      line-height: 24px;
    }
  }

  .opener:hover {
    color: #333;
  }

  .sparkl-tree-children {
    box-sizing: border-box;
  }

  .selectable {
    border-radius: 2px;
  }

  &.selected {
    & > .sparkl-tree-title {
      background: rgba(54, 155, 233, 0.75);
      color: white;
      border-radius: 3px;

      .opener:hover {
        color: white;
      }
    }
  }
}
</style>
