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
    :class="classes"
    v-draggable
    @drag-start="started"
    @drag-stop="stopped"
    @drag-move="dragMove">
    <div class="icon">
      <icon :name="icon"/>
    </div>
    <div class="title">{{name}}</div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex'
import util from '../util'
import draggable from '../mixins/draggable'

export default {
  props: ['name', 'icon', 'minified'],
  mixins: [draggable],
  data () {
    return {
      pressed: false
    }
  },
  methods: {
    started () {
      this.drag.tag = this.name
      this.borders = util.domrect.borders('.sparkl-node.container')
    },
    stopped () {
      if (this.drag.target) {
        var parentId = this.drag.target.id
        var parent = this.nodes[parentId]
        var insertIndex = -1

        if (parent && this.drag.closest) {
          var closest = this.drag.closest
          var type = util.type.is(this.name)
          var siblingId = closest.box.id
          var siblingDir = type === 'container' ? closest.y : closest.x

          insertIndex = parent.content.indexOf(siblingId)
          insertIndex += Math.max(0, siblingDir)
        }

        this.$store.commit('createStruct', {
          tag: this.name,
          parent_id: parentId,
          $position: insertIndex
        })

        this.dragClean()
        this.dragCleanCache()
      }
    }
  },
  computed: {
    ...mapGetters([
      'nodes'
    ]),
    classes () {
      return [
        'subject',
        this.name,
        this.pressed && 'pressed',
        this.minified && 'minified'
      ]
    }
  }
}
</script>
