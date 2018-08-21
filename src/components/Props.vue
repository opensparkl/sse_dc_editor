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
<modal
  name="props"
  :width="900"
  :height="500"
  :resizable="true"
  :min-height="300"
  :min-width="400"
  classes="v--modal modal-props"
  draggable=".props-modal-header-bar"
  @before-open="beforeOpened"
  @before-close="beforeClosed">
  <template v-if="selected">
      <div class="props-modal-header-bar">
        <div class="props-title">
          "{{selected.attr.name}}" properties
        </div>
        <ul class="tab-list"
            style="width:300px; margin-bottom: -1px; position: absolute; top: 0; right: 0;">
          <li :class="{ active: tab == 'attr' }">
            <button @click="changeTab('attr')">Attributes</button>
          </li>
          <li :class="{ active: tab == 'content' }">
            <button @click="changeTab('content')">Content</button>
          </li>
        </ul>
      </div>
      <div class="props-content">
        <div class="props-sidebar">
          <div class="props-list">
            <div
              v-for="prop in props"
              class="prop-name"
              :class="{selected: prop.attr.id === selectedPropId}"
              @click="selectProp(prop.attr.id)">
              <input
                type="text"
                placeholder="Property name"
                :value="prop.attr.name"
                @input="updatePropName(prop.attr.id, $event)">
              <i class="fa fa-fw fa-remove"
                 @click.stop="removeProp(prop.attr.id)"></i>
            </div>
          </div>
          <div class="hint-container">
            <HelpButton
              v-for="item in missingProps"
              :params="item"
              @click="createProp(item.value)"
              @hover="showTooltip"
              @hout="hideTooltip"/>
          </div>
          <button
            class="add-button"
            @click.stop="createProp()">
            +
          </button>
      </div>
      <div class="props-tabs">
        <template v-if="selectedProp">
          <div v-if="tab === 'attr'"
               class="props-tab tab-attr">
            <table class="prop-attr-table">
              <tbody>
                <tr v-for="(at, index) in attr"
                    v-if="!ignored(at[0])"
                    :key="index">
                  <td>
                    <input v-model="at[0]"
                           type="text"
                           placeholder="Key"
                           @input="updateAttrs">
                  </td>
                  <td>
                    <SelectInput
                      :list="attrErrors.$options[at[0]]"
                      :value="at[1]"
                      @input="setSelectInputValue(at, $event, index)"/>
                  </td>
                  <td>
                    <i class="fa fa-fw fa-remove"
                       @click="removeAttr(index)"/>
                  </td>
                </tr>
            </tbody>
          </table>
          <div class="hint-container">
            <HelpButton
              v-for="item in attrErrors.missing_attribute"
              :params="item"
              @click="createAttr(item.value)"
              @hover="showTooltip"
              @hout="hideTooltip"/>
          </div>
          <button class="add-button"
                  @click.stop="createAttr()">+</button>
        </div>
        <div class="props-tab tab-content" v-if="tab == 'content'">
          <CodeEditor
            v-if="visibleEditor"
            v-model="content"
            :options="options"/>
        </div>
      </template>
    </div>
  </div>
  </template>
</modal>
</template>
<script>
import _ from 'lodash'
import Tree from '../util/tree'
import CodeEditor from './CodeEditor'
import { mapGetters } from 'vuex'
import config from '../config'
import util from '../util'
import xslt from '../util/xslt'
import HelpButton from './HelpButton'
import SelectInput from './SelectInput'

export default {
  name: 'PropsModal',
  components: {
    CodeEditor,
    SelectInput,
    HelpButton
  },
  data () {
    return {
      selectedPropId: null,
      tab: 'attr',
      tooltip: '',
      visibleEditor: false,
      tooltipStyle: {},
      attr: [],
      mimes: config.mimeTypes,
      content: '',
      missingProps: [],
      attrErrors: {},
      options: { mode: 'text/plain' }
    }
  },
  computed: {
    ...mapGetters([
      'selected',
      'nodes'
    ]),
    props () {
      return this.selected.content
        .map(id => this.nodes[id])
        .filter(v => v.tag === 'prop')
    },
    selectedProp () {
      return _.find(this.props, v => v.attr.id === this.selectedPropId)
    }
  },
  methods: {
    setSelectInputValue (container, event, index) {
      this.$set(container, 1, event.value)
    },
    updateEditorMode (attr) {
      var type = attr['content-type'] || null
      var mode = type && config.mimeTypes.indexOf(type) !== -1
        ? type
        : 'text/plain'

      this.options = { mode }
    },
    changeTab (name) {
      if (this.selectedPropId) {
        this.updateSelectedProp()

        if (name === 'content') {
          this.updateEditorMode(this.selectedProp.attr)
        }
      }

      this.tab = name
    },
    showTooltip (event) {
      var bottom = window.innerHeight - event.rect.bottom +
        event.rect.height + 5

      var message = event.message

      if (event.params.help) {
        var helpURL = config.docsUrl + event.params.help

        if (message.length > 0) {
          message += '<br>'
        }

        message += `<sub><a target="_blank" href="${helpURL}">Click to learn more...</a></sub>`
      }

      this.$tooltip.show(message, {
        bottom: bottom + 'px',
        left: event.rect.left + 'px'
      })
    },
    hideTooltip () {
      this.$tooltip.hide()
    },
    hintMissingAttrs () {
      var id = this.selectedProp.attr.id
      var parentId = this.selected.parent_id
      var xml = Tree.xml(this.nodes, parentId, {
        emptyAttr: true
      })

      xslt.transform('validation', xml, messages => {
        var errorsByType = {
          $options: {}
        }

        util.forEachElement(messages, `[ref="${id}"]`, el => {
          var attr = util.attrsFor(el)
          var msg = el.querySelector('msg')
          var i = attr.message

          if (msg) {
            attr.$msg = msg.getAttribute('key')
          }

          attr.$type = el.nodeName
          errorsByType[i] = (errorsByType[i] || []).concat(attr)

          if (i === 'attribute_value') {
            var options = util.mapElements(el, 'option',
              option => option.getAttribute('value'))

            errorsByType.$options[attr.value] = options
          }
        })

        this.$set(this, 'attrErrors', errorsByType)
      }, id)
    },
    hintMissingProps () {
      var id = this.selected.attr.id
      var selector = `[message="missing_prop"][ref="${id}"]`
      var xml = Tree.xml(this.nodes, this.rootId)

      xslt.transform('validation', xml, messages => {
        // var list = messages.querySelectorAll(selector);
        var missing = []

        util.forEachElement(messages, selector, el => {
          var item = util.attrsFor(el)
          var msg = el.querySelector('msg')

          if (msg) {
            item.$msg = msg.getAttribute('key')
          }

          item.$type = el.nodeName
          missing.push(item)
        })

        this.$set(this, 'missingProps', missing)
      }, id)
    },
    ignored (value) {
      return value === 'id' || value === 'name'
    },
    beforeOpened (event) {
      if (this.props.length > 0) {
        var p = this.props[0]
        this.selectProp(p.attr.id)
      }

      this.hintMissingProps()
    },
    beforeClosed () {
      this.updateSelectedProp()

      this.attr = []
      this.content = ''
      this.selectedPropId = null
      this.$tooltip.hide()
    },
    createProp (name) {
      var prop = Tree.create(this.nodes, {
        tag: 'prop',
        attr: {
          name: name || util.randomNodeName('prop')
        },
        value: ''
      }, {
        append: true
      })

      Tree.parent(this.nodes, prop, this.selected.attr.id)
      this.selectProp(prop.attr.id)
      this.hintMissingAttrs()
    },
    removeProp (id) {
      Tree.remove(this.nodes, id)
      this.hintMissingProps()
    },
    updatePropName (id, event) {
      this.$set(this.nodes[id].attr, 'name', event.target.value)
      this.hintMissingProps()
      this.hintMissingAttrs()
    },
    updateSelectedProp () {
      if (this.selectedProp) {
        var filtered = this.attr.filter(v => v[0].trim() !== '')
        var attr = _.fromPairs(filtered)

        attr.name = this.selectedProp.attr.name

        this.$set(this.selectedProp, 'value', this.content || '')
        this.$set(this.selectedProp, 'attr', attr)
      }
    },
    selectProp (id) {
      if (this.selectedPropId) {
        this.updateSelectedProp()
      }

      this.selectedPropId = id
      var prop = this.selectedProp

      this.$set(this, 'content', prop.value || '')

      this.attr = _.map(prop.attr, (value, key) => [key, value])
      this.attr = _.sortBy(this.attr, v => v[0])

      // if (this.tab === 'content') {
      this.visibleEditor = false
      this.updateEditorMode(prop.attr)

      this.$nextTick(() => {
        this.visibleEditor = true
      })
      // }

      this.hintMissingProps()
      this.hintMissingAttrs()
    },
    createAttr (key = '') {
      this.attr.push([key, ''])
      this.updateSelectedProp()

      if (key !== '') {
        this.hintMissingAttrs()
      }
    },
    removeAttr (i) {
      this.attr.splice(i, 1)
      this.updateSelectedProp()
      this.hintMissingAttrs()
    },
    updateAttrs () {
      this.updateSelectedProp()
      this.hintMissingAttrs()
    }
  }
}
</script>
<style lang="scss">
  .tooltip {
    a {
      color: black;
    }
  }
</style>
