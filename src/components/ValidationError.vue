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
    v-if="isVisible"
    ref="self"
    class="global-box validation-error"
    :style="style"
    @mouseenter="mouseenter"
    @mouseleave="mouseleave">
    <table class="error-table-tooltip">
      <tr
        class="ett-tr"
        v-for="error in nodeErrors"
        @click="gotoHelp(error)">
        <td>
          <span :class="['tl-name', error.errorType]">
              <i :class="icon(error.errorType, error.help)"/>
              <span> {{error.errorType}}</span>
          </span>
        </td>
        <td>
          <span>{{error.context}}</span>
          <span>({{error.nodeName}})</span>
          <span>{{error.message}}</span>
          <span v-if="error.value">: {{error.value}}</span>
        </td>
      </tr>
    </table>
  </div>
</template>
<script>
import { mapState } from 'vuex'
import config from '../config'

export default {
  name: 'ValidationError',
  data () {
    return {
      isMouseOver: false,
      isVisible: false,
      style: null,
      timeout: null
    }
  },
  watch: {
    nodeOverId: function (id) {
      if (id === null) {
        this.timeout = setTimeout(() => {
          if (this.isMouseOver === false) {
            this.isVisible = false
          }
        }, 300)
        return
      } else {
        this.clearTimeout()
      }

      var node = this.nodes[id]

      if (node.tag === 'reply' || node.tag === 'response') {
        this.$store.commit('setNodeOverId', node.parent_id)
        return
      }

      this.nodeErrors = this.errors[id] || []
      this.isVisible = this.nodeErrors.length > 0

      if (this.isVisible) {
        this.$nextTick(() => {
          this.style = this.position(id)
        })
      }
    }
  },
  computed: {
    ...mapState([
      'errors',
      'nodeOverId',
      'nodes'
    ])
  },
  methods: {
    gotoHelp (error) {
      let help = error.help

      if (help) {
        let url = config.docsUrl + help
        window.open(url, help)
      }
    },

    icon (type, hasHelp) {
      return [
        'fa fa-fw',
        type === 'warning' ? 'fa-info-circle' : 'fa-times-circle',
        !!hasHelp && 'pinging'
      ]
    },

    position (id) {
      var target = document
        .querySelector('.sparkl-node#' + id)

      if (target) {
        var rect = target.getBoundingClientRect()

        var left = rect.left + window.scrollX
        var top = rect.top + window.scrollY

        var height = this.$refs.self.offsetHeight
        var gap = 10

        var _left = Math.max(left, 0)
        var _top = Math.max(top - height - gap, 0)

        return {
          left: _left + 'px',
          top: _top + 'px'
        }
      }

      return null
    },

    mouseenter () {
      this.isMouseOver = true
    },

    mouseleave () {
      this.isMouseOver = false
      this.isVisible = false
      this.clearTimeout()
    },

    clearTimeout () {
      if (this.timeout) {
        clearTimeout(this.timeout)
      }
    }
  }
}
</script>
<style lang="scss">
  .fa.fa-fw.pinging {
    position: relative;
    cursor: pointer;
  }

  .ett-tr {
    cursor: help;
  }
</style>
