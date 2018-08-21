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
  <div :class="nodeClass"
       :id="id">
    <table class="operation-table">
      <tr
        v-for="(subject, i) in subjects"
        class="s-node-header"
        :class="[ subject.tag, 'droppable' ]"
        :id="subject.attr.id">
        <td
          :class="{'s-node-title': true, 'select-border': subject.attr.id === selectedId}"
          @mousedown="select(subject.attr.id)"
          @mouseenter="mouseover"
          @mouseleave="mouseleave">
          <div class="s-n-name-field">
            <div class="title-top">{{subject.attr.name}}</div>
            <div class="title-bottom">{{subject.attr.service}}</div>
          </div>
          <i class="fa fa-remove fa-fw"
             @mousedown.stop="remove(subject.attr.id)">
          </i>
        </td>
        <td class="s-node-fields">
          <field
            v-for="fieldId in subject.attr.fields"
            :parent="subject"
            :node="nodes[fieldId]"></field>
        </td>
      </tr>
      <tr
        v-if="isExtendable"
        class="s-node-add-content">
        <td @mousedown.stop="append">+</td>
        <td></td>
      </tr>
    </table>
  </div>
</template>
<script>
  import Type from '../util/type'
  import Field from './Field.vue'

  import controller from '../mixins/node.js'
  import draggable from '../mixins/draggable'

  export default {
    name: 'Operation',
    mixins: [controller, draggable],
    components: { Field },
    computed: {
      subjects () {
        return [this.node].concat(
          this.node.content
            .map(i => this.nodes[i])
            .filter(v => Type.is(v) === 'operation')
        )
      },

      fields () {
        if (!this.node.attr.fields) {
          this.node.attr.fields = []
        }

        return this.node.attr.fields.map(i => this.nodes[i])
      },

      isExtendable () {
        return Type.isExtendable(this.node.tag)
      }
    },
    methods: {
      append () {
        if (this.isExtendable) {
          var tag = this.node.tag === 'solicit'
            ? 'response'
            : 'reply'

          var content = this.node.content
          var length = content
            .filter(id => Type.isReply(this.nodes[id]))
            .length

          var params = {
            tag: tag,
            attr: {},
            parent_id: this.node.attr.id
          }

          if (length === 0) {
            params.attr.name = 'Ok'
          }

          if (length === 1) {
            params.attr.name = 'Error'
          }

          this.$store.commit('createStruct', params)
        }
      }
    }
  }
</script>
