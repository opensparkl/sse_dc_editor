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
    :class="nodeClass"
    :id="id"
    :data-type="node.tag === 'field' ? (node.attr.type || 'flag') : ''"
    @mouseenter="mouseover"
    @mouseleave="mouseleave">
    <div class="s-node-header">
      <div :class="titleClass">
        <div class="s-n-name-field">
          <i
            v-if="icon"
            :class="icon"
            aria-hidden="true"/>
          {{node.attr.name}}
        </div>
        <i
          class="fa fa-remove fa-fw"
          @mousedown.stop="remove(id)"
          aria-hidden="true"/>
      </div>
    </div>
  </div>
</template>
<script>
  import controller from '../mixins/node'
  import draggable from '../mixins/draggable'
  export default {
    mixins: [controller, draggable],
    computed: {
      titleClass () {
        return {
          's-node-title': true,
          'select-border': this.id === this.selectedId
        }
      }
    }
  }
</script>
