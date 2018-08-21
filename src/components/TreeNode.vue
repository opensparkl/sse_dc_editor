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
  <div
    class="sparkl-tree-node"
    :class="classes">
    <div
      class="sparkl-tree-title"
      :style="style"
      @click.stop="select(source.attr.path, $event)">
      <i
        :class="icon"
        @click.stop="open(source.attr.path)"/>
      <span class="selectable">
        <i :class="icon2"/>
        {{source.attr.name}}
      </span>
    </div>
    <div v-if="isOpened"
         class="sparkl-tree-children">
      <template v-for="(child, i) in children">
          <tree-node
            :state="state"
            :source="child"
            :class="'i-' + i"
            :level="level + 1"
            @select="bubble"/>
      </template>
    </div>
  </div>
</template>
<script>
import api from '../api'

export default {
  name: 'TreeNode',
  props: {
    state: {
      type: Object,
      required: true
    },
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
    classes () {
      return {
        root: this.source.attr.path === '',
        selected: this.state.path === this.source.attr.path
      }
    }
  },
  methods: {
    bubble (event) {
      this.$emit('select', event)
    },
    select (path, event) {
      this.state.path = this.state.path === path
        ? null
        : path

      this.$emit('select', {
        source: this.source,
        level: this.level,
        state: this.state,
        srcEvent: event
      })
    },
    open (path) {
      if (this.isOpened) {
        this.isOpened = false
        this.children = []
      } else {
        api.content(path).then(response => {
          var content = response.data.content

          if (content) {
            this.children = content.filter(v => {
              return v.tag === 'folder' || v.tag === 'mix'
            })
          } else {
            this.children = []
          }

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

    /*&:not(.root) > .sparkl-tree-title:before {
      display: block;
      position: absolute;
      z-index: 2;
      display: block;
      content: '';
      height: 24px;
      width: 5px;
      left: 0;
      top: -12px;
      border-left: 1px solid #666666;
      border-bottom: 1px solid #666666;
    }

    &.i-0:not(.root) > .sparkl-tree-title:before {
      top: -9px;
      height: 20px;
    }*/

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
