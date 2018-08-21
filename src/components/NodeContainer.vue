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
    :class="containerClass"
    :id="id"
    :key="id"
    @mousedown="isRoot && select()">
    <div class="s-node-background">
    </div>
    <div
      class="s-node-header"
      @mouseenter="mouseover"
      @mouseleave="mouseleave">
      <div class="s-node-title">
        <div class="s-n-name-field">
          <i
            v-if="rootId !== node.attr.id"
            :class="['fa fa-fw fa-sort-desc', folded && 'fa-rotate-270']"
            @mousedown.stop="folded = !folded"></i>
          <i :class="icon"></i>
          <span>{{node.attr.name}}</span>
          <span style="color: #999; font-size: 10px;"
                v-if="rootId == node.attr.id && source"> ({{source.folder}})</span>
        </div>
        <i
          v-if="rootId === node.attr.id"
          class="fa fa-refresh"
          style="opacity: 0.1"
          :class="{syncronized}"
          aria-hidden="true"></i>
        <i
          class="fa fa-remove"
          @mousedown.stop="remove(id)"></i>
      </div>
    </div>
    <div
      v-if="!folded"
      class="s-node-content"
      @mousedown.stop="unselect">
      <div class="centered-container owns-service">
        <basic
          v-for="v in groups.service"
          v-draggable="draggableOptions"
          @drag-start="dragStarted"
          @drag-move="dragMove"
          @drag-stop="dragStopped"
          :id="v.attr.id"
          :key="v.attr.id"/>
      </div>
      <div class="centered-container owns-field">
        <basic
          v-for="v in groups.field"
          v-draggable="draggableOptions"
          @drag-start="dragStarted"
          @drag-move="dragMove"
          @drag-stop="dragStopped"
          :id="v.attr.id"
          :key="v.attr.id"/>
      </div>
      <div class="owns-operation">
        <operation
          v-for="v in groups.operation"
          v-draggable="draggableOptions"
          @drag-start="dragStarted"
          @drag-move="dragMove"
          @drag-stop="dragStopped"
          :id="v.attr.id"
          :key="v.attr.id"/>
      </div>
      <container
        v-for="v in groups.container"
        v-draggable="draggableOptions"
        @drag-start="dragStarted"
        @drag-move="dragMove"
        @drag-stop="dragStopped"
        :id="v.attr.id"
        :key="v.attr.id"/>
    </div>
  </div>
</template>
<script>
  import Type from '../util/type'
  import Operation from './NodeOperation.vue'
  import Basic from './NodeBasic.vue'
  import controller from '../mixins/node.js'
  import draggable from '../mixins/draggable'
  import Tree from '../util/tree'
  import domrect from '../util/domrect'
  import {mapGetters} from 'vuex'

  export default {
    name: 'Container',
    mixins: [controller, draggable],
    components: {Operation, Basic},
    props: ['isRoot'],
    data: function () {
      return {
        folded: false,
        draggableOptions: {stickiness: 15},
        order: ['service', 'field', 'operation', 'container']
      }
    },
    computed: {
      ...mapGetters([
        'source',
        'rootId',
        'syncronized'
      ]),
      containerClass () {
        return [
          this.nodeClass,
          'droppable',
          {
            'select-border': this.id === this.selectedId
          }
        ]
      },
      groups () {
        var content = this.node.content
        var groups = {}

        for (var i = 0; i < content.length; i++) {
          var id = content[i]
          var node = this.nodes[id]

          if (Type.isRenderable(node.tag)) {
            var type = Type.is(node.tag)

            if (!groups[type]) {
              groups[type] = []
            }

            groups[type].push(node)
          }
        }

        return groups
      }
    },
    methods: {
      dragStarted (event) {
        var id = event.el.id
        var node = this.nodes[id]
        var type = Type.is(node)
        var ignored = []

        this.drag.id = id
        this.drag.tag = node.tag

        if (type === 'container') {
          ignored = Tree
            .searchDown(this.nodes, id, {}, {skipSiblings: true})
            .map(v => v.attr.id)
            .concat(id)
        }

        var selector = '.droppable'

        if (type !== 'field' && type !== 'service') {
          selector += '.container'
        }

        var droppable = document.body.querySelectorAll(selector) || []
        var borders = {}

        for (let i = 0; i < droppable.length; i++) {
          let el = droppable[i]
          let id = el.id

          if (ignored.indexOf(id) !== -1) {
            continue
          }

          borders[id] = {
            el,
            id,
            rect: el.getBoundingClientRect(),
            depth: domrect.depth(el)
          }
        }

        this.borders = borders
      },

      dragStopped (event) {
        var id = this.drag.id
        var node = this.nodes[id]
        var type = Type.is(node)

        var targetId = this.drag.target && this.drag.target.id

        if (targetId) {
          var target = this.nodes[targetId]
          var targetType = Type.is(target)

          if (targetType === 'container') {
            var insertIndex = -1

            if (this.drag.closest) {
              var closest = this.drag.closest

              var siblingId = closest.box.id
              var siblingDir = type === 'container' ? closest.y : closest.x

              insertIndex = target.content.indexOf(siblingId)
              insertIndex += Math.max(0, siblingDir)
            }

            this.$store.commit('moveStruct', {
              id,
              to: targetId,
              at: insertIndex
            })
          }

          if (targetType === 'operation') {
            var error = null

            if (type === 'field') {
              error = Tree.addFieldRef(this.nodes, targetId, id)
            }

            if (type === 'service') {
              error = Tree.addServiceRef(this.nodes, targetId, id)
            }

            if (error) {
              this.$notify({
                type: 'error',
                text: error,
                duration: 600000
              })
            }
          }

          this.dragClean()
          this.dragCleanCache()
        }

        if (type !== 'operation' && event.distance < 5 && targetId !== id) {
          this.select(id)
        }
      }
    }
  }
</script>
